#!/usr/bin/env bash

cmds=$(
for f in $(find . -mindepth 1 -maxdepth 1 -name '.*' ! -name '.git' -a ! -name '.*swp' | sed 's|./||' | grep -v .vscode); do
  echo "(cd; ln -fs .dotfiles/$f .)"
done)

echo "$cmds"
read -rp "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sh -c "$cmds"
fi
