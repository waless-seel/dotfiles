(&mise activate pwsh) | Out-String | Invoke-Expression

Import-Module Terminal-Icons -ErrorAction SilentlyContinue
if (-not [Console]::IsOutputRedirected -and -not [Console]::IsInputRedirected) {
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
}

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

$_pythonHome = & mise where python 2>$null
if ($LASTEXITCODE -eq 0 -and $_pythonHome) {
    $env:PATH = "$_pythonHome\Scripts;$env:PATH"
}
Remove-Variable _pythonHome -ErrorAction SilentlyContinue

. "$PSScriptRoot\pwsh_git.ps1"
. "$PSScriptRoot\pwsh_util.ps1"

