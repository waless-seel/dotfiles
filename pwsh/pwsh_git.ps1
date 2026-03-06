# fzf を使用した git ブランチ切り替え (gsw)
function gsw {
    $branch = git branch --list | fzf --preview "git log -1 --color=always {}"
    if ($branch) {
        $branchName = $branch -replace '^\s*\*?\s*'
        git switch $branchName
    }
}

# リモートブランチを含めたブランチ切り替え (gswa)
function gswa {
    $branch = git branch -a | fzf --preview "git log -1 --color=always {}"
    if ($branch) {
        $branchName = $branch -replace '^\s*\*?\s*' -replace '^remotes/origin/'
        git switch $branchName
    }
}

# ローカルブランチ削除 (gbd)
function gbd {
    $currentBranch = git branch --show-current
    $mergedBranches = git branch --merged | ForEach-Object { ($_ -replace '^\s*\*?\s*').Trim() }
    $branches = git branch --list | Where-Object { $_ -notmatch '^\*' } |
        ForEach-Object {
            $name = ($_ -replace '^\s*').Trim()
            if ($mergedBranches -contains $name) {
                "$([char]27)[32m[merged]$([char]27)[0m   $name"
            } else {
                "[unmerged] $name"
            }
        } |
        fzf --ansi --multi --preview "git log -1 --color=always {2}" --header "merged into: $currentBranch"
    if ($branches) {
        $branches | ForEach-Object {
            $branchName = ($_ -replace '^\[.*?\]\s+').Trim()
            git branch -D $branchName
        }
    }
}

# ログブラウザ
function glf {
    git log --oneline --color=always |
        fzf --ansi --preview "git show --color=always {1}" `
            --preview-window=right:60%:wrap
}
