eval "$(mise activate zsh)"

eval "$(starship init zsh)"      # zsh の場合
# eval "$(starship init bash)"   # bash の場合は手動で切り替え
eval "$(zoxide init zsh)"

# スクリプトディレクトリを取得（bash/zsh 共通）
if [[ -n "${BASH_SOURCE[0]}" ]]; then
  _ZSH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  _ZSH_DIR="${${(%):-%x}:h}"
fi

source "${_ZSH_DIR}/zsh_git.sh"
source "${_ZSH_DIR}/zsh_util.sh"
