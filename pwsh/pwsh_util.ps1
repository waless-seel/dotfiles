# fzf でディレクトリを選択して移動
function fcd {
    $dir = fd --type d --hidden --exclude .git 2>/dev/null |
        fzf --preview "eza -la --color=always {} 2>/dev/null || ls {}"
    if ($dir) { Set-Location $dir }
}

# mkdir + cd を一発で
function mkcd($dir) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Set-Location $dir
}

# n 階層上に移動（デフォルト 1）
function up([int]$n = 1) {
    Set-Location ("../" * $n)
}

# fzf でファイルを選択してエディタで開く（bat でプレビュー）
function fe {
    $file = fd --type f --hidden --exclude .git 2>/dev/null |
        fzf --preview "bat --color=always --style=numbers {}"
    if ($file) { & ($env:EDITOR ?? "code") $file }
}

# Linux 互換 touch
function touch($file) {
    if (Test-Path $file) {
        (Get-Item $file).LastWriteTime = Get-Date
    } else {
        New-Item -ItemType File -Path $file | Out-Null
    }
}

# カレントパスをクリップボードへコピー
function cppath {
    (Get-Location).Path | Set-Clipboard
    Write-Host "Copied: $((Get-Location).Path)"
}

# fzf でプロセスを選択して停止
function fkill {
    $procs = Get-Process | ForEach-Object { "{0,-8} {1}" -f $_.Id, $_.Name } |
        fzf --multi --header "Select process(es) to kill (Tab for multi-select)"
    if ($procs) {
        $procs | ForEach-Object {
            $id = ($_ -split '\s+')[0]
            Stop-Process -Id $id -Force
            Write-Host "Killed PID $id"
        }
    }
}

# rg + fzf でファイル内容を検索してエディタで開く
function fgrep($pattern) {
    if (-not $pattern) { $pattern = "" }
    $result = rg --line-number --color=always $pattern |
        fzf --ansi --delimiter ":" --preview "bat --color=always --highlight-line {2} {1}"
    if ($result) {
        $file = ($result -split ":")[0]
        & ($env:EDITOR ?? "code") $file
    }
}

# fzf で環境変数を検索・表示
function fenv {
    Get-ChildItem Env: |
        ForEach-Object { "$($_.Name)=$($_.Value)" } |
        fzf --preview "echo {}"
}

# Linux 互換 which
function which($cmd) {
    (Get-Command $cmd -ErrorAction SilentlyContinue)?.Source
}

# Ctrl+R を fzf 履歴検索に上書き
Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
    $historyFile = (Get-PSReadLineOption).HistorySavePath
    $cmd = Get-Content $historyFile -ErrorAction SilentlyContinue |
        Where-Object { $_ -ne "" } |
        Get-Unique |
        fzf --tac --no-sort --height 40% --prompt "history> "
    if ($cmd) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd)
    }
}

# eza があれば ll / lt を定義
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ll { eza -la --git --color=always @args }
    function lt { eza -la --git --tree --color=always @args }
}
