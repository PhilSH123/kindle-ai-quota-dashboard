param([switch]$Publish)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$secretPath = Join-Path $repoRoot 'config/secrets.clixml'
$configPath = Join-Path $repoRoot 'config.json'

if (-not (Test-Path -LiteralPath $configPath)) {
  Copy-Item -LiteralPath (Join-Path $repoRoot 'config.example.json') -Destination $configPath
}
if (-not (Test-Path -LiteralPath $secretPath)) {
  throw '尚未配置密钥。请先运行 scripts/setup-secrets.ps1。'
}

$secrets = Import-Clixml -LiteralPath $secretPath
$env:DEEPSEEK_API_KEY = [pscredential]::new('local', $secrets.DeepSeek).GetNetworkCredential().Password
$env:GLM_CODING_API_KEY = [pscredential]::new('local', $secrets.Glm).GetNetworkCredential().Password
$codexExe = Get-Command codex.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
if (-not $codexExe) {
  $codexBin = Join-Path $env:LOCALAPPDATA 'OpenAI/Codex/bin'
  $codexExe = Get-ChildItem -LiteralPath $codexBin -Filter codex.exe -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $codexExe) { throw '找不到 Codex 可执行文件 codex.exe。' }
$env:CODEX_CLI_PATH = $codexExe

try {
  Push-Location $repoRoot
  try {
    npm run update:extras
    if ($LASTEXITCODE -ne 0) { throw '天气或每日一语更新失败' }
    npm run collect
    if ($LASTEXITCODE -ne 0) { throw '额度采集失败' }
    npm run build
    if ($LASTEXITCODE -ne 0) { throw '页面构建失败' }
    if ($Publish) { & (Join-Path $PSScriptRoot 'publish-pages.ps1') }
  } finally {
    Pop-Location
  }
} finally {
  Remove-Item Env:DEEPSEEK_API_KEY, Env:GLM_CODING_API_KEY, Env:CODEX_CLI_PATH -ErrorAction SilentlyContinue
}
