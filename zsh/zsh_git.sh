# fzf を使用した git ブランチ切り替え (gsw)
function gsw() {
  local branch
  branch=$(git branch --list | fzf --preview "git log -1 --color=always {}")
  if [[ -n "$branch" ]]; then
    local branch_name
    branch_name=$(echo "$branch" | sed 's/^[[:space:]]*\*\?[[:space:]]*//')
    git switch "$branch_name"
  fi
}

# リモートブランチを含めたブランチ切り替え (gswa)
function gswa() {
  local branch
  branch=$(git branch -a | fzf --preview "git log -1 --color=always {}")
  if [[ -n "$branch" ]]; then
    local branch_name
    branch_name=$(echo "$branch" | sed 's/^[[:space:]]*\*\?[[:space:]]*//')
    branch_name="${branch_name#remotes/origin/}"
    git switch "$branch_name"
  fi
}

# ローカルブランチ削除 (gbd)
function gbd() {
  local current_branch
  current_branch=$(git branch --show-current)

  local merged_branches
  merged_branches=$(git branch --merged | sed 's/^[[:space:]]*\*\?[[:space:]]*//')

  local entries=()
  while IFS= read -r line; do
    # skip current branch (lines starting with *)
    [[ "$line" =~ ^\* ]] && continue
    local name
    name=$(echo "$line" | sed 's/^[[:space:]]*//')
    if echo "$merged_branches" | grep -qx "$name"; then
      entries+=("$'\033'[32m[merged]$'\033'[0m   $name")
    else
      entries+=("[unmerged] $name")
    fi
  done < <(git branch --list)

  local selected
  selected=$(printf '%s\n' "${entries[@]}" | fzf --ansi --multi \
    --preview "git log -1 --color=always \$(echo {} | awk '{print \$NF}')" \
    --header "merged into: $current_branch")

  if [[ -n "$selected" ]]; then
    while IFS= read -r entry; do
      local branch_name
      branch_name=$(echo "$entry" | awk '{print $NF}')
      if ! git branch -d "$branch_name" 2>/dev/null; then
        git branch -D "$branch_name"
      fi
    done <<< "$selected"
  fi
}

# ログブラウザ
function glf() {
  git log --oneline --color=always |
    fzf --ansi --preview "git show --color=always {1}" \
        --preview-window=right:60%:wrap
}
