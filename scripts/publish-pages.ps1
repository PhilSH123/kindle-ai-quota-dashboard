$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$pagesRoot = Join-Path $repoRoot '.pages-publish'
$distRoot = Join-Path $repoRoot 'dist'

function Invoke-DirectGit([string[]]$GitArgs) {
  $previousConfig = $env:GIT_CONFIG_GLOBAL
  try {
    # This machine rewrites github.com to a read-only download mirror globally.
    $env:GIT_CONFIG_GLOBAL = 'NUL'
    & git -c credential.helper=manager @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "GitHub 操作失败：$($GitArgs[0])" }
  } finally {
    if ($null -eq $previousConfig) { Remove-Item Env:GIT_CONFIG_GLOBAL -ErrorAction SilentlyContinue }
    else { $env:GIT_CONFIG_GLOBAL = $previousConfig }
  }
}

if (-not (Test-Path -LiteralPath $distRoot)) { throw '尚未生成 dist，请先运行 scripts/run-dashboard.ps1。' }
$snapshot = Get-Content -LiteralPath (Join-Path $distRoot 'data.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($name in @('codex', 'deepseek', 'glm')) {
  if (-not $snapshot.sources.$name.ok) { throw "$name 尚未成功采集；已停止公开发布。" }
}
if (-not $snapshot.weather.ok) { throw '天气尚未成功采集；已停止公开发布。' }
if (-not $snapshot.quote.text) { throw '每日一语尚未生成；已停止公开发布。' }
npm --prefix $repoRoot run check
if ($LASTEXITCODE -ne 0) { throw '公开前检查未通过。' }
$repoAbsolute = [IO.Path]::GetFullPath($repoRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
$pagesAbsolute = [IO.Path]::GetFullPath($pagesRoot)
if (-not $pagesAbsolute.StartsWith($repoAbsolute, [StringComparison]::OrdinalIgnoreCase)) {
  throw '发布目录不在项目内，已停止。'
}

if (-not (Test-Path -LiteralPath (Join-Path $pagesRoot '.git'))) {
  if (Test-Path -LiteralPath $pagesRoot) { throw '发布目录已存在且不是 Git 仓库，请人工检查。' }
  $sourceUrl = git -C $repoRoot config --get remote.origin.url
  Invoke-DirectGit -GitArgs @('clone', '--quiet', $sourceUrl, $pagesRoot)
  $remotePages = Invoke-DirectGit -GitArgs @('-C', $pagesRoot, 'ls-remote', '--heads', 'origin', 'gh-pages')
  if ($remotePages) { git -C $pagesRoot checkout --quiet --track origin/gh-pages }
  else { git -C $pagesRoot checkout --quiet --orphan gh-pages }
  if ($LASTEXITCODE -ne 0) { throw '切换 gh-pages 分支失败' }
}

$branch = git -C $pagesRoot branch --show-current
if ($branch -ne 'gh-pages') { throw '发布目录当前不是 gh-pages 分支，已停止。' }

# Remove only files inside the verified dedicated publishing checkout.
Get-ChildItem -LiteralPath $pagesRoot -Force | Where-Object { $_.Name -ne '.git' } |
  ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
Copy-Item -Path (Join-Path $distRoot '*') -Destination $pagesRoot -Recurse -Force
Copy-Item -LiteralPath (Join-Path $distRoot '.nojekyll') -Destination $pagesRoot -Force

git -C $pagesRoot add -A
if ($LASTEXITCODE -ne 0) { throw '暂存页面失败' }
git -C $pagesRoot diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host '页面内容未变化，检查是否有待推送的提交。' }
else {
  git -C $pagesRoot commit --quiet -m 'Update dashboard snapshot'
  if ($LASTEXITCODE -ne 0) { throw '提交页面失败' }
}
Invoke-DirectGit -GitArgs @('-C', $pagesRoot, 'push', 'origin', 'gh-pages')
Write-Host '已推送 gh-pages 分支。'
