# レジストリから最新 PATH を反映
$env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')

# pwsh_util.ps1 を読み込む
$utilPath = "$PSScriptRoot\..\pwsh\pwsh_util.ps1"
try {
    . $utilPath
    Write-Host "OK  dot-source pwsh_util.ps1" -ForegroundColor Green
} catch {
    Write-Host "NG  dot-source failed: $_" -ForegroundColor Red
    exit 1
}

$pass = 0
$fail = 0

function Assert($label, $actual, $expected) {
    if ($actual -eq $expected) {
        Write-Host "OK  $label" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "NG  $label  (expected='$expected' actual='$actual')" -ForegroundColor Red
        $script:fail++
    }
}

function AssertDefined($name) {
    if (Get-Command $name -ErrorAction SilentlyContinue) {
        Write-Host "OK  $name is defined" -ForegroundColor Green
        $script:pass++
    } else {
        Write-Host "NG  $name is NOT defined" -ForegroundColor Red
        $script:fail++
    }
}

Write-Host ""
Write-Host "--- 関数定義チェック ---"
foreach ($fn in @('fcd','mkcd','up','fe','touch','cppath','fkill','fgrep','fenv','which')) {
    AssertDefined $fn
}

Write-Host ""
Write-Host "--- mkcd ---"
$testDir = Join-Path $env:TEMP "pwsh_util_test_$(Get-Random)"
mkcd $testDir
Assert "mkcd: directory created" (Test-Path $testDir) $true
Assert "mkcd: current location changed" ((Get-Location).Path) $testDir
Set-Location $env:TEMP
Remove-Item $testDir -Force

Write-Host ""
Write-Host "--- up ---"
$before = (Get-Location).Path
Set-Location $env:TEMP
$tempDepth = Join-Path $env:TEMP "a\b\c"
New-Item -ItemType Directory -Path $tempDepth -Force | Out-Null
Set-Location $tempDepth
up 2
$expected = (Resolve-Path (Join-Path $env:TEMP "a")).Path
Assert "up 2: moved 2 levels up" ((Get-Location).Path) $expected
Set-Location $env:TEMP
Remove-Item (Join-Path $env:TEMP "a") -Recurse -Force
Set-Location $before

Write-Host ""
Write-Host "--- touch ---"
$tmpFile = Join-Path $env:TEMP "touch_test_$(Get-Random).txt"
# 新規作成
touch $tmpFile
Assert "touch: new file created" (Test-Path $tmpFile) $true
# 既存ファイルの更新
$before = (Get-Item $tmpFile).LastWriteTime
Start-Sleep -Milliseconds 100
touch $tmpFile
$after = (Get-Item $tmpFile).LastWriteTime
Assert "touch: LastWriteTime updated" ($after -gt $before) $true
Remove-Item $tmpFile -Force

Write-Host ""
Write-Host "--- which ---"
$fzfPath = which fzf
Assert "which fzf: returns path" ($null -ne $fzfPath -and $fzfPath -like '*fzf*') $true
$nope = which __no_such_command__
Assert "which missing: returns null" ($null -eq $nope) $true

Write-Host ""
Write-Host "--- ll / lt (eza) ---"
if (Get-Command eza -ErrorAction SilentlyContinue) {
    AssertDefined 'll'
    AssertDefined 'lt'
} else {
    Write-Host "SKIP ll/lt: eza not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- fzf 系（定義のみ・非インタラクティブのためスキップ）---"
foreach ($fn in @('fcd','fe','fkill','fgrep','fenv')) {
    Write-Host "SKIP $fn (requires interactive TTY)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================="
Write-Host "PASS: $pass  FAIL: $fail" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
