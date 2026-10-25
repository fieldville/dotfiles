#!/usr/bin/env bash
#
# Symlink each dotfile in this repo into $HOME, asking per file.
#
#   ./setup.bash        ask for each file (y / n / a = yes to all / q = quit)
#   ./setup.bash -y     link everything without asking

set -u
cd "$(dirname "$0")" || exit 1
repo=$(basename "$PWD")

yes_all=0
[[ ${1:-} == -y ]] && yes_all=1

link() {
  (cd ~ && ln -fs "$repo/$1" .) && echo "  linked ~/$1 -> $repo/$1"
}

# Describe what currently sits at ~/$1 so the user can decide.
status() {
  local t=~/$1
  if [[ -L $t ]]; then
    local dest; dest=$(readlink "$t")
    if [[ $dest == "$repo/$1" ]]; then echo "already linked"
    else echo "symlink -> $dest"
    fi
  elif [[ -e $t ]]; then echo "exists (will be overwritten)"
  else echo "new"
  fi
}

for f in $(find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.git' ! -name '.*swp' \
             | sed 's|^\./||' | sort); do
  if (( yes_all )); then
    link "$f"
    continue
  fi

  read -rp "$f  [$(status "$f")]  link? (y/N/a/q) " -n 1
  echo
  case $REPLY in
    [Yy]) link "$f" ;;
    [Aa]) yes_all=1; link "$f" ;;
    [Qq]) echo "aborted"; exit 0 ;;
    *)    echo "  skipped $f" ;;
  esac
done

# ---- VS Code: link vscode/* (settings.json, keybindings.json, snippets/) into the
# user settings dir. VS Code watches those files, so after this `git pull` alone updates
# the running editor. In WSL the editor is the Windows one and reads the Windows-side
# settings (link those with setup.ps1), so nothing is done here.
vscode_user_dir() {
  case $(uname -s) in
    Darwin) echo "$HOME/Library/Application Support/Code/User" ;;
    Linux)  grep -qi microsoft /proc/version 2>/dev/null && return 1
            echo "${XDG_CONFIG_HOME:-$HOME/.config}/Code/User" ;;
    *)      return 1 ;;
  esac
}

link_vscode() {
  local dir=$1 name src dst
  mkdir -p "$dir"
  for src in "$PWD"/vscode/*; do
    name=$(basename "$src"); dst=$dir/$name
    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
      echo "  already linked $dst"; continue
    fi
    if [[ -e $dst && ! -L $dst ]]; then
      local bak=$dst.bak
      [[ -e $bak ]] && bak=$dst.$(date +%Y%m%d%H%M%S).bak   # keep earlier backups
      mv "$dst" "$bak" && echo "  backed up $dst -> $bak"
    fi
    ln -sfn "$src" "$dst" && echo "  linked $dst -> $src"
  done
}

if dir=$(vscode_user_dir); then
  if (( yes_all )); then
    link_vscode "$dir"
  else
    read -rp "vscode/*  -> $dir  link? (y/N) " -n 1
    echo
    case $REPLY in
      [Yy]) link_vscode "$dir" ;;
      *)    echo "  skipped vscode" ;;
    esac
  fi
else
  echo "vscode: skipped (WSL or unknown OS; on Windows run setup.ps1)"
fi
