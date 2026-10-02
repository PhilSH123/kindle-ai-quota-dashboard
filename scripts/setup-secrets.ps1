$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$secretPath = Join-Path $repoRoot 'config/secrets.clixml'

Write-Host '密钥只会以当前 Windows 用户可解密的形式保存在本机 config/secrets.clixml。'
$deepSeek = Read-Host '请输入 DeepSeek API Key' -AsSecureString
$glm = Read-Host '请输入 GLM Coding Plan API Key' -AsSecureString
if ($deepSeek.Length -eq 0 -or $glm.Length -eq 0) { throw '两个密钥都必须填写。' }
[pscustomobject]@{ DeepSeek = $deepSeek; Glm = $glm } | Export-Clixml -LiteralPath $secretPath
Write-Host '已保存本机密钥。请不要把这个文件复制给别人。'
