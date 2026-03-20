(&mise activate pwsh) | Out-String | Invoke-Expression

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

. "$PSScriptRoot\pwsh_git.ps1"
. "$PSScriptRoot\pwsh_util.ps1"
