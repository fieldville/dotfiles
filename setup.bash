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

for f in $(find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.git' ! -name '.*swp' ! -name '.vscode' \
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
