$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$pagesRoot = Join-Path $repoRoot '.pages-publish'
$distRoot = Join-Path $repoRoot 'dist'

if (-not (Test-Path -LiteralPath $distRoot)) { throw '尚未生成 dist，请先运行 scripts/run-dashboard.ps1。' }
$snapshot = Get-Content -LiteralPath (Join-Path $distRoot 'data.json') -Raw | ConvertFrom-Json
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
  git clone --quiet (git -C $repoRoot remote get-url origin) $pagesRoot
  if ($LASTEXITCODE -ne 0) { throw '克隆发布仓库失败' }
  $remotePages = git -C $pagesRoot ls-remote --heads origin gh-pages
  if ($LASTEXITCODE -ne 0) { throw '检查 gh-pages 分支失败' }
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
if ($LASTEXITCODE -eq 0) { Write-Host '页面内容未变化'; exit 0 }
git -C $pagesRoot commit --quiet -m 'Update dashboard snapshot'
if ($LASTEXITCODE -ne 0) { throw '提交页面失败' }
git -C $pagesRoot push origin gh-pages
if ($LASTEXITCODE -ne 0) { throw '推送 GitHub Pages 失败' }
Write-Host '已推送 gh-pages 分支。'
