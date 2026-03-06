# Dependency Tools Installer
# pwsh_util.ps1 / pwsh_git.ps1 で使用するツールを winget でインストールする

$ColorGreen  = 'Green'
$ColorYellow = 'Yellow'
$ColorRed    = 'Red'
$ColorCyan   = 'Cyan'

# winget の存在確認
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: winget が見つかりません。Microsoft Store から 'App Installer' をインストールしてください。" -ForegroundColor $ColorRed
    exit 1
}

# ツール定義: @{ Id; Command; Description }
$tools = @(
    [pscustomobject]@{ Id = 'junegunn.fzf';              Command = 'fzf';      Description = 'fuzzy finder (fcd / fe / fkill / fgrep / Ctrl+R)' }
    [pscustomobject]@{ Id = 'sharkdp.fd';                Command = 'fd';       Description = 'fast find 代替 (fcd / fe)' }
    [pscustomobject]@{ Id = 'sharkdp.bat';               Command = 'bat';      Description = 'syntax highlight cat (fe / fgrep preview)' }
    [pscustomobject]@{ Id = 'BurntSushi.ripgrep.MSVC';   Command = 'rg';       Description = 'fast grep (fgrep)' }
    [pscustomobject]@{ Id = 'eza-community.eza';          Command = 'eza';      Description = 'ls 代替・カラー対応 (ll / lt / fcd preview)' }
    [pscustomobject]@{ Id = 'ajeetdsouza.zoxide';         Command = 'zoxide';   Description = 'スマートな cd 代替 (z / zi)' }
    [pscustomobject]@{ Id = 'Starship.Starship';          Command = 'starship'; Description = 'プロンプト (profile で使用)' }
    [pscustomobject]@{ Id = 'dandavison.delta';           Command = 'delta';    Description = 'git diff pager (推奨)' }
    [pscustomobject]@{ Id = 'JesseDuffield.lazygit';      Command = 'lazygit';  Description = 'TUI git クライアント (推奨)' }
)

function Test-CommandExists($name) {
    $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

function Install-Tool($tool) {
    Write-Host "  Installing $($tool.Id) ..." -ForegroundColor $ColorYellow
    winget install --id $tool.Id --silent --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] $($tool.Id)" -ForegroundColor $ColorGreen
    } else {
        Write-Host "  [FAIL] $($tool.Id) (exit code: $LASTEXITCODE)" -ForegroundColor $ColorRed
    }
}

Write-Host ""
Write-Host "Dependency Tools Installer" -ForegroundColor $ColorCyan
Write-Host "==========================" -ForegroundColor $ColorCyan
Write-Host ""

$toInstall   = @()
$alreadyHave = @()

foreach ($tool in $tools) {
    if (Test-CommandExists $tool.Command) {
        $alreadyHave += $tool
    } else {
        $toInstall += $tool
    }
}

# インストール済みツール一覧
if ($alreadyHave.Count -gt 0) {
    Write-Host "インストール済み:" -ForegroundColor $ColorGreen
    foreach ($tool in $alreadyHave) {
        Write-Host "  [OK] $($tool.Command.PadRight(10)) $($tool.Description)" -ForegroundColor $ColorGreen
    }
    Write-Host ""
}

# 未インストールツール一覧
if ($toInstall.Count -eq 0) {
    Write-Host "すべてのツールがインストール済みです。" -ForegroundColor $ColorGreen
    exit 0
}

Write-Host "未インストール:" -ForegroundColor $ColorYellow
foreach ($tool in $toInstall) {
    Write-Host "  [ ] $($tool.Command.PadRight(10)) $($tool.Description)" -ForegroundColor $ColorYellow
}
Write-Host ""

$response = Read-Host "上記 $($toInstall.Count) 件をインストールしますか? (y/n)"
if ($response -ne 'y' -and $response -ne 'Y') {
    Write-Host "キャンセルしました。" -ForegroundColor $ColorYellow
    exit 0
}

Write-Host ""
foreach ($tool in $toInstall) {
    Install-Tool $tool
}

Write-Host ""
Write-Host "完了しました。PATH を反映するためターミナルを再起動してください。" -ForegroundColor $ColorCyan
