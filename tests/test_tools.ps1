# レジストリから最新の PATH を取得してセッションに反映
$machinePath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$userPath    = [Environment]::GetEnvironmentVariable('PATH', 'User')
$env:PATH    = "$machinePath;$userPath"

foreach ($t in @('fzf','fd','bat','rg','eza','zoxide','starship','delta','lazygit')) {
    $c = Get-Command $t -ErrorAction SilentlyContinue
    if ($c) {
        $v = & $t --version 2>&1 | Select-Object -First 1
        Write-Host "OK  $($t.PadRight(10)) $v" -ForegroundColor Green
    } else {
        Write-Host "NG  $t" -ForegroundColor Red
    }
}
