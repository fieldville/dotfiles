# PowerShell counterpart of .falias (fzf helper functions, mostly from
# https://github.com/junegunn/fzf/wiki/Examples). Dot-sourced from
# Microsoft.PowerShell_profile.ps1 when fzf is on PATH. Keep the two in sync.
#
# Differences from the bash version:
#  - fzf runs --preview / --bind commands through cmd.exe on Windows, so the awk/sed/xargs
#    pipelines are replaced by fzf field tokens ({2} = 2nd whitespace-separated field) or by
#    a PowerShell loop around fzf (fshow, fstash).
#  - `sed 1d` + `fzf` is replaced by `fzf --header-lines=1`, which keeps the header visible.
#  - fzf-tmux's dynamic height is approximated with `--height=~100%`.
#  - fkill uses Get-Process / Stop-Process (no signal argument on Windows).
#  - brew helpers (bup / bcp) have no counterpart.
#
# Every function returns silently when fzf is cancelled (Esc / Ctrl+c -> exit code 130)
# or nothing is selected, so no git/docker command runs with an empty argument.

########################################
# fzf defaults. PSFzf honours these too: FZF_CTRL_T_COMMAND / FZF_ALT_C_COMMAND are run
# with Invoke-Expression (so plain native commands work) and FZF_CTRL_T_OPTS is appended
# to FZF_DEFAULT_OPTS for the Ctrl+t picker. Each is set only when its tool is installed,
# so a fresh machine falls back to fzf's / PSFzf's built-in defaults.
if (Get-Command fd -ErrorAction Ignore) {
  $env:FZF_DEFAULT_COMMAND = 'fd -H -E .git/ -L'
  $env:FZF_ALT_C_COMMAND   = 'fd -H -E .git/ -L -t d'
}
if (Get-Command rg -ErrorAction Ignore) {
  $env:FZF_CTRL_T_COMMAND = 'rg --files --hidden --follow --glob "!.git/*"'
}
if (Get-Command bat -ErrorAction Ignore) {
  $env:FZF_CTRL_T_OPTS = '--preview "bat --color=always --style=header,grid --line-range :100 {}"'
}

########################################
# fkill - kill processes (multi-select). bash: ps | fzf -m | xargs kill -9
function fkill {
  $header = '{0,7}  {1,-30} {2}' -f 'PID', 'NAME', 'WINDOW TITLE'
  $lines = Get-Process | Sort-Object ProcessName, Id |
    ForEach-Object { '{0,7}  {1,-30} {2}' -f $_.Id, $_.ProcessName, $_.MainWindowTitle }
  $sel = @($header) + @($lines) | fzf -m --header-lines=1
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  $ids = @($sel) | ForEach-Object { [int]($_.Trim() -split '\s+')[0] }
  Stop-Process -Id $ids -Force
}

########################################
# fbr - checkout git branch (local branches, with tracking info)
function fbr {
  $branch = git branch -vv | fzf +m
  if ($LASTEXITCODE -ne 0 -or -not $branch) { return }
  git checkout (($branch -replace '^[*+]?\s*', '') -split '\s+')[0]
}

# fbrm - checkout git branch (including remote branches)
function fbrm {
  $branch = git branch --all | Where-Object { $_ -notmatch 'HEAD' } | fzf +m --height=~100%
  if ($LASTEXITCODE -ne 0 -or -not $branch) { return }
  git checkout (($branch -replace '^[*+]?\s*', '') -replace '^remotes/[^/]*/', '')
}

# fbrms - checkout git branch, sorted by most recent commit, limit 30 last branches
function fbrms {
  $branch = git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)' |
    fzf +m --height=~100%
  if ($LASTEXITCODE -ne 0 -or -not $branch) { return }
  git checkout $branch
}

# Branches ("branch<TAB>name", current branch and remote HEAD excluded) followed by tags
# ("tag<TAB>name"), colored like the bash version. git itself expands %1B / %09 in --format,
# so the branch line needs no shell escaping; the tag prefix is built here instead of awk.
function _fzfGitRefs {
  $esc = [char]27
  $branches = git --no-pager branch --all `
    --format='%(if)%(HEAD)%(then)%(else)%(if:equals=HEAD)%(refname:strip=3)%(then)%(else)%1B[0;34;1mbranch%09%1B[m%(refname:short)%(end)%(end)' |
    Where-Object { $_ }
  $tags = git --no-pager tag | ForEach-Object { "$esc[35;1mtag$esc[m`t$_" }
  @($branches) + @($tags)
}

# fco_preview - checkout git branch/tag, with a preview showing the commits between the
# tag/branch and HEAD. `fco` is this one, as in bash (alias fco='fco_preview').
function fco_preview {
  $target = _fzfGitRefs | fzf --no-hscroll --no-multi -n 2 --ansi `
    --preview 'git --no-pager log -150 --pretty=format:%s ..{2}'
  if ($LASTEXITCODE -ne 0 -or -not $target) { return }
  git checkout ($target -split '\s+')[1]
}
Set-Alias fco fco_preview

# fcop - pick a git branch/tag and print its name (for use in other commands)
function fcop {
  $target = _fzfGitRefs | fzf --no-hscroll --no-multi -n 2 --ansi
  if ($LASTEXITCODE -ne 0 -or -not $target) { return }
  ($target -split '\s+')[1]
}

# fcoc - checkout git commit
function fcoc {
  $commit = git log --pretty=oneline --abbrev-commit --reverse | fzf --tac +s +m -e
  if ($LASTEXITCODE -ne 0 -or -not $commit) { return }
  git checkout ($commit -split ' ')[0]
}

# fshow - git commit browser: Enter shows the commit (git's pager), back to the list on quit,
# Esc leaves. Extra arguments go to git log (e.g. `fshow --all`, `fshow -- path`).
# bash binds ctrl-m to `git show | less` inside fzf; that needs sh, so loop here instead.
function fshow {
  while ($true) {
    $sel = git log --graph --color=always --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' @args |
      fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort
    if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
    if ($sel -match '[a-f0-9]{7,}') { git show $Matches[0] }
  }
}

# gadd - git add with multi-select and a diff preview
# https://dev.classmethod.jp/articles/fzf-original-app-for-git-add/
function gadd {
  $sel = git -c color.status=always status -s | fzf -m --ansi --preview 'git diff --color -- {2}'
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  $files = @($sel) | ForEach-Object { ($_.Trim() -split '\s+')[1] }
  git add -- $files
  "Completed: git add $files"
}

# fcs - get git commit sha
# example usage: git rebase -i (fcs)
function fcs {
  $commit = git log --color=always --pretty=oneline --abbrev-commit --reverse |
    fzf --tac +s +m -e --ansi --reverse
  if ($LASTEXITCODE -ne 0 -or -not $commit) { return }
  ($commit -split ' ')[0]
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
function fstash {
  $q = ''
  while ($true) {
    # --print-query + --expect: line 0 = query, line 1 = key pressed ('' for Enter), last = selection
    $out = @(git stash list --pretty='%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs' |
      fzf --ansi --no-sort "--query=$q" --print-query --expect=ctrl-d,ctrl-b)
    if ($LASTEXITCODE -ne 0) { return }
    $q = $out[0]
    $k = $out[1]
    $sha = ($out[-1] -split ' ')[0]
    if ($out.Count -lt 3 -or -not $sha) { continue }
    if ($k -eq 'ctrl-d') {
      git diff $sha
    } elseif ($k -eq 'ctrl-b') {
      git stash branch "stash-$sha" $sha
      break
    } else {
      git stash show -p $sha
    }
  }
}

########################################
# fda - select a docker container to start and attach to
function fda {
  param($q)
  $sel = docker ps -a | fzf --header-lines=1 -1 "--query=$q"
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  $cid = ($sel -split '\s+')[0]
  docker start $cid
  if ($LASTEXITCODE -eq 0) { docker attach $cid }
}

# fds - select a running docker container to stop
function fds {
  param($q)
  $sel = docker ps | fzf --header-lines=1 "--query=$q"
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  docker stop ($sel -split '\s+')[0]
}

# fdrm - select docker container(s) to remove
function fdrm {
  param($q)
  $sel = docker ps -a | fzf --header-lines=1 "--query=$q" --no-sort -m --tac
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  docker rm (@($sel) | ForEach-Object { ($_ -split '\s+')[0] })
}

# fdrmi - select docker image(s) to remove (3rd column = IMAGE ID)
function fdrmi {
  param($q)
  $sel = docker images | fzf --header-lines=1 "--query=$q" --no-sort -m --tac
  if ($LASTEXITCODE -ne 0 -or -not $sel) { return }
  docker rmi (@($sel) | ForEach-Object { ($_ -split '\s+')[2] })
}
