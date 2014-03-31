#!/usr/bin/env bash

cmds=$(
  for f in `ls -1ad .* | grep -v '.git$' | grep -v '^.$' | grep -v '^..$' | grep -v '.swp' | sed 's@/$@@'`
  do
    echo "(cd; ln -fs .dotfiles/$f .)"
  done
)

echo "$cmds"
read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  sh -c "$cmds"
fi
