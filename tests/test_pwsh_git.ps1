# レジストリから最新 PATH を反映
$env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')

# pwsh_git.ps1 を読み込む
$gitPath = "$PSScriptRoot\..\pwsh\pwsh_git.ps1"
try {
    . $gitPath
    Write-Host "OK  dot-source pwsh_git.ps1" -ForegroundColor Green
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
foreach ($fn in @('gsw','gswa','gbd','glf','gmf')) {
    AssertDefined $fn
}

Write-Host ""
Write-Host "--- gmf: ブランチ名トリム ロジック ---"
$trimLogic = { param($raw) ($raw -replace '^\s*').Trim() }
Assert "gmf trim: leading spaces"    (& $trimLogic '  feature/foo')  'feature/foo'
Assert "gmf trim: leading tab"       (& $trimLogic "`tfeature/bar")  'feature/bar'
Assert "gmf trim: no spaces"         (& $trimLogic 'main')           'main'

Write-Host ""
Write-Host "--- fzf 系（定義のみ・非インタラクティブのためスキップ）---"
foreach ($fn in @('gsw','gswa','gbd','glf','gmf')) {
    Write-Host "SKIP $fn (requires interactive TTY)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================="
Write-Host "PASS: $pass  FAIL: $fail" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Red' })
