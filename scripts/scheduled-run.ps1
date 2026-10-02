$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$logRoot = Join-Path $repoRoot 'logs'
New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
$logPath = Join-Path $logRoot 'scheduled.log'
$env:GCM_INTERACTIVE = 'never'
$env:GIT_TERMINAL_PROMPT = '0'

Start-Transcript -Path $logPath -Append | Out-Null
try {
  & (Join-Path $PSScriptRoot 'run-dashboard.ps1') -Publish
  Write-Host '定时更新已完成。'
} catch {
  Write-Host "定时更新失败：$($_.Exception.Message)"
  exit 1
} finally {
  Stop-Transcript | Out-Null
}
