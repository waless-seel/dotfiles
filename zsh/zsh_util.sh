# fzf でディレクトリを選択して移動
function fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null |
    fzf --preview "eza -la --color=always {} 2>/dev/null || ls -la {}")
  if [[ -n "$dir" ]]; then
    cd "$dir"
  fi
}

# mkdir + cd を一発で
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# n 階層上に移動（デフォルト 1）
function up() {
  local n="${1:-1}"
  local path=""
  for ((i = 0; i < n; i++)); do
    path="../$path"
  done
  cd "$path"
}

# fzf でファイルを選択してエディタで開く（bat でプレビュー）
function fe() {
  local file
  file=$(fd --type f --hidden --exclude .git 2>/dev/null |
    fzf --preview "bat --color=always --style=numbers {}")
  if [[ -n "$file" ]]; then
    "${EDITOR:-code}" "$file"
  fi
}

# カレントパスをクリップボードへコピー
function cppath() {
  local path
  path=$(pwd)
  if command -v clip.exe >/dev/null 2>&1; then
    echo -n "$path" | clip.exe                           # WSL
  elif command -v pbcopy >/dev/null 2>&1; then
    echo -n "$path" | pbcopy                             # macOS
  elif command -v xclip >/dev/null 2>&1; then
    echo -n "$path" | xclip -selection clipboard         # Linux
  elif command -v xsel >/dev/null 2>&1; then
    echo -n "$path" | xsel --clipboard --input           # Linux alt
  else
    echo "No clipboard utility found" >&2; return 1
  fi
  echo "Copied: $path"
}

# fzf でプロセスを選択して停止
function fkill() {
  local procs
  procs=$(ps aux | tail -n +2 |
    fzf --multi --header "Select process(es) to kill (Tab for multi-select)")
  if [[ -n "$procs" ]]; then
    while IFS= read -r proc; do
      local pid
      pid=$(echo "$proc" | awk '{print $2}')
      kill -9 "$pid"
      echo "Killed PID $pid"
    done <<< "$procs"
  fi
}

# rg + fzf でファイル内容を検索してエディタで開く
function fgrep() {
  local pattern="${1:-}"
  local result
  result=$(rg --line-number --color=always "$pattern" |
    fzf --ansi --delimiter ":" --preview "bat --color=always --highlight-line {2} {1}")
  if [[ -n "$result" ]]; then
    local file
    file=$(echo "$result" | cut -d: -f1)
    "${EDITOR:-code}" "$file"
  fi
}

# fzf で環境変数を検索・表示
function fenv() {
  env | fzf --preview "echo {}"
}

# Ctrl+R を fzf 履歴検索に上書き
function _fzf_history() {
  local selected
  selected=$(fc -ln 1 | awk '!x[$0]++' | fzf --tac --no-sort --height 40% --prompt "history> ")
  if [[ -n "$selected" ]]; then
    if [[ -n "$ZSH_VERSION" ]]; then
      LBUFFER="$selected"
      zle reset-prompt
    else
      READLINE_LINE="$selected"
      READLINE_POINT=${#selected}
    fi
  fi
}

if [[ -n "$ZSH_VERSION" ]]; then
  zle -N _fzf_history
  bindkey '^R' _fzf_history
elif [[ -n "$BASH_VERSION" ]]; then
  bind -x '"\C-r": _fzf_history'
fi

# eza があれば ll / lt を定義
if command -v eza >/dev/null 2>&1; then
  function ll() { eza -la --git --color=always "$@"; }
  function lt() { eza -la --git --tree --color=always "$@"; }
fi
