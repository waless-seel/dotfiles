#!/usr/bin/env bash
# Dependency Tools Installer for WSL / macOS / Linux
# zsh_util.sh / zsh_git.sh で使用するツールをインストールする

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ツール定義: "command|apt_pkg|brew_pkg|pacman_pkg|dnf_pkg|description"
# !script = curl ベースのインストールスクリプトで対応
TOOLS=(
  "fzf|fzf|fzf|fzf|fzf|fuzzy finder (fcd / fe / fkill / fgrep / Ctrl+R)"
  "fd|fd-find|fd|fd|fd-find|fast find 代替 (fcd / fe)"
  "bat|bat|bat|bat|bat|syntax highlight cat (fe / fgrep preview)"
  "rg|ripgrep|ripgrep|ripgrep|ripgrep|fast grep (fgrep)"
  "eza|eza|eza|eza|eza|ls 代替・カラー対応 (ll / lt / fcd preview)"
  "zoxide|zoxide|zoxide|zoxide|zoxide|スマートな cd 代替 (z / zi)"
  "starship|!script|starship|starship|!script|プロンプト (profile で使用)"
  "delta|git-delta|git-delta|git-delta|git-delta|git diff pager (推奨)"
  "lazygit|!script|lazygit|lazygit|!script|TUI git クライアント (推奨)"
)

# ----- パッケージマネージャ検出 -----
detect_pkg_manager() {
  if command -v brew >/dev/null 2>&1; then
    echo "brew"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  else
    echo "unknown"
  fi
}

# ----- コマンド存在確認 -----
# fd は apt では fdfind というバイナリ名になる場合がある
cmd_exists() {
  local cmd="$1"
  if [[ "$cmd" == "fd" ]]; then
    command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1
  else
    command -v "$cmd" >/dev/null 2>&1
  fi
}

# エントリからパッケージ名を取得
get_pkg() {
  local entry="$1" pkg_manager="$2"
  IFS='|' read -r _cmd apt_pkg brew_pkg pacman_pkg dnf_pkg _desc <<< "$entry"
  case "$pkg_manager" in
    brew)   echo "$brew_pkg" ;;
    apt)    echo "$apt_pkg" ;;
    pacman) echo "$pacman_pkg" ;;
    dnf)    echo "$dnf_pkg" ;;
    *)      echo "!manual" ;;
  esac
}

# ----- スクリプトインストール関数 -----
install_starship() {
  echo -e "  ${YELLOW}starship をインストールスクリプト経由でインストールします...${RESET}"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

install_lazygit() {
  echo -e "  ${YELLOW}lazygit を GitHub Releases 経由でインストールします...${RESET}"

  local version
  version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  if [[ -z "$version" ]]; then
    echo -e "  ${RED}[FAIL] lazygit: バージョン取得に失敗しました${RESET}" >&2
    return 1
  fi

  local arch
  case "$(uname -m)" in
    x86_64)         arch="x86_64" ;;
    aarch64|arm64)  arch="arm64" ;;
    *)              arch="x86_64" ;;
  esac

  local url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_${arch}.tar.gz"
  local tmp_dir
  tmp_dir=$(mktemp -d)

  curl -fsSLo "$tmp_dir/lazygit.tar.gz" "$url" \
    && tar xf "$tmp_dir/lazygit.tar.gz" -C "$tmp_dir" lazygit \
    && sudo install "$tmp_dir/lazygit" /usr/local/bin/lazygit

  rm -rf "$tmp_dir"
}

# ----- ツールインストール -----
install_tool() {
  local entry="$1" pkg_manager="$2"
  IFS='|' read -r cmd _apt _brew _pacman _dnf _desc <<< "$entry"

  local pkg
  pkg=$(get_pkg "$entry" "$pkg_manager")

  if [[ "$pkg" == "!script" ]]; then
    case "$cmd" in
      starship) install_starship ;;
      lazygit)  install_lazygit ;;
      *)
        echo -e "  ${RED}[SKIP] $cmd: 手動インストールが必要です${RESET}" >&2
        return 1
        ;;
    esac
  elif [[ "$pkg" == "!manual" ]]; then
    echo -e "  ${RED}[SKIP] $cmd: このパッケージマネージャでは未対応です。手動でインストールしてください。${RESET}" >&2
    return 1
  else
    echo -e "  ${YELLOW}Installing $pkg ...${RESET}"
    case "$pkg_manager" in
      brew)   brew install "$pkg" ;;
      apt)    sudo apt-get install -y "$pkg" ;;
      pacman) sudo pacman -S --noconfirm "$pkg" ;;
      dnf)    sudo dnf install -y "$pkg" ;;
    esac
  fi

  if cmd_exists "$cmd"; then
    echo -e "  ${GREEN}[OK] $cmd${RESET}"
  else
    echo -e "  ${RED}[FAIL] $cmd${RESET}" >&2
  fi
}

# ===== メイン処理 =====
PKG_MANAGER=$(detect_pkg_manager)

echo -e ""
echo -e "${CYAN}Dependency Tools Installer${RESET}"
echo -e "${CYAN}==========================${RESET}"
echo -e "${CYAN}Package manager: $PKG_MANAGER${RESET}"
echo -e ""

if [[ "$PKG_MANAGER" == "unknown" ]]; then
  echo -e "${RED}ERROR: サポートされるパッケージマネージャが見つかりません (brew / apt / pacman / dnf)${RESET}" >&2
  exit 1
fi

to_install=()
already_have=()

for entry in "${TOOLS[@]}"; do
  IFS='|' read -r cmd _a _b _c _d _desc <<< "$entry"
  if cmd_exists "$cmd"; then
    already_have+=("$entry")
  else
    to_install+=("$entry")
  fi
done

# インストール済みツール表示
if [[ ${#already_have[@]} -gt 0 ]]; then
  echo -e "${GREEN}インストール済み:${RESET}"
  for entry in "${already_have[@]}"; do
    IFS='|' read -r cmd _a _b _c _d desc <<< "$entry"
    printf "${GREEN}  [OK] %-12s %s${RESET}\n" "$cmd" "$desc"
  done
  echo ""
fi

# 未インストールツール表示
if [[ ${#to_install[@]} -eq 0 ]]; then
  echo -e "${GREEN}すべてのツールがインストール済みです。${RESET}"
  exit 0
fi

echo -e "${YELLOW}未インストール:${RESET}"
for entry in "${to_install[@]}"; do
  IFS='|' read -r cmd _a _b _c _d desc <<< "$entry"
  printf "${YELLOW}  [ ] %-12s %s${RESET}\n" "$cmd" "$desc"
done
echo ""

read -r -p "上記 ${#to_install[@]} 件をインストールしますか? (y/n): " response
if [[ "$response" != "y" && "$response" != "Y" ]]; then
  echo -e "${YELLOW}キャンセルしました。${RESET}"
  exit 0
fi

echo ""

# apt の場合は先に update
if [[ "$PKG_MANAGER" == "apt" ]]; then
  echo -e "${CYAN}apt-get update を実行します...${RESET}"
  sudo apt-get update -q
  echo ""
fi

for entry in "${to_install[@]}"; do
  install_tool "$entry" "$PKG_MANAGER"
done

echo ""
echo -e "${CYAN}完了しました。PATH を反映するためターミナルを再起動してください。${RESET}"
