# Git aliases: PowerShell counterpart of .galias (bash/zsh) in this repo, dot-sourced from
# Microsoft.PowerShell_profile.ps1 like falias.ps1. Keep the two in sync when adding one.
# PowerShell resolves aliases before functions, so built-in aliases that collide with ours
# (gc=Get-Content, gl=Get-Location, gp=Get-ItemProperty, gm=Get-Member, gcm=Get-Command,
# gci=Get-ChildItem) are removed first; otherwise the functions never run.
foreach ($name in 'gl', 'gc', 'gp', 'gm', 'gcm', 'gci') {
  if (Test-Path "alias:$name") { Remove-Item "alias:$name" -Force }
}

Set-Alias g git
Set-Alias get git

# clone / add / reset
function gcl { git clone @args }
function ga { git add @args }
function gall { git add . }
function grh { git reset HEAD @args }
function grhh { git reset HEAD --hard @args }
function gclean { git reset --hard; if ($LASTEXITCODE -eq 0) { git clean -dfx } }

# status
function gst { git status @args }
function gs { git status @args }
function gss { git status -s @args }

# pull / push / fetch
function gl { git pull @args }
function gpr { git pull --rebase @args }
function glr { git pull --rebase @args }   # PowerShell-only (kept for existing habit)
function gpp { git pull; if ($LASTEXITCODE -eq 0) { git push } }
function gup { git fetch; if ($LASTEXITCODE -eq 0) { git rebase @args } }
function gp { git push @args }
function gpo { git push origin @args }

# diff
function gd { git diff @args }
function gdv { git diff -w @args | nvim -R - }

# commit
function gc { git commit -v @args }
function gca { git commit -v -a @args }
function gci { git commit --interactive @args }

# checkout / branch / merge / cherry-pick
function gco { git checkout @args }
function gcm { git checkout main }
function gcma { git checkout master }
function gb { git branch @args }
function gba { git branch -a @args }
function gbr { git branch --remote @args }
function gdel { git branch -D @args }
function gm { git merge @args }
function gmu { git fetch origin -v; git fetch upstream -v; git merge upstream/main }
function gmua { git fetch origin -v; git fetch upstream -v; git merge upstream/master }
function gcp { git cherry-pick @args }

# rebase
function grbi { git rebase -i @args }
function grbc { git rebase --continue }
function grba { git rebase --abort }

# log
function gll { git log --graph --pretty=oneline --abbrev-commit @args }
function gg { git log --graph '--pretty=format:%h -%d %s (%cr)' --abbrev-commit --date=relative @args }
function ggs { gg --stat @args }
function glg { git log --stat --max-count=10 @args }
function glgg { git log --graph --max-count=10 @args }
function glgga { git log --graph --decorate --all @args }
function glo { git log --oneline --decorate --color @args }
function glog { git log --oneline --decorate --color --graph @args }
function gw { git whatchanged @args }
function gcount { git shortlog -sn @args }
function gsl { git shortlog -sn @args }

# tag
function gt { git tag @args }
function gta { git ls-remote --tags @args }
function gtd { git tag -d @args }
function gtl { git tag -l @args }

# remote
function grv { git remote -v }
function grmv { git remote rename @args }
function grrm { git remote remove @args }
function grset { git remote set-url @args }
function grup { git remote update @args }

# config
function gcfg { git config --list @args }
function gori { git config --list --show-origin @args }   # PowerShell-only

# stash
function gsta { git stash @args }
function gstp { git stash pop @args }
function gstd { git stash drop @args }
function gsts { git stash show --text @args }

# misc
function gexport { git archive --format zip --output @args }
function grt {
  # cd to the repository root (bash: cd $(git rev-parse --show-cdup))
  $top = git rev-parse --show-toplevel 2>$null
  if ($top) { Set-Location $top }
}
