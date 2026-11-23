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

# ---- macOS: key repeat. Holding h/j/k/l (or an arrow) repeats at KeyRepeat * 15 ms after
# InitialKeyRepeat * 15 ms; the OS defaults (6 / 68) make cursor movement in a terminal feel
# slow. KeyRepeat 1.3 is below what the System Settings slider allows (2), so set it here; do
# not touch the slider afterwards or it snaps back. Takes effect after logging out and in.
mac_key_repeat() {
  local want_rate=1.3 want_delay=25 rate delay
  rate=$(defaults read -g KeyRepeat 2>/dev/null); delay=$(defaults read -g InitialKeyRepeat 2>/dev/null)
  if [[ $rate == "$want_rate" && $delay == "$want_delay" ]]; then
    echo "  already set (KeyRepeat $rate, InitialKeyRepeat $delay)"; return
  fi
  defaults write -g KeyRepeat -float "$want_rate" &&
  defaults write -g InitialKeyRepeat -int "$want_delay" &&
  echo "  set KeyRepeat ${rate:-unset} -> $want_rate, InitialKeyRepeat ${delay:-unset} -> $want_delay (log out to apply)"
}

# ---- macOS: Terminal.app "Use Option as Meta key" for the default and the startup profile.
# Without it Option+key types a symbol (Option+1 -> ¡) and tmux never sees M-1 .. M-5 / M-o.
# useOptionAsMetaKey = true is what the profile stores for "both Option keys". Edited through
# defaults export / import so cfprefsd sees it; a profile Terminal has not saved yet is skipped
# (open Terminal once, then rerun). Applies to windows opened after restarting Terminal.
mac_terminal_option_meta() {
  local pb=/usr/libexec/PlistBuddy tmp key name entry done_names=: changed=0
  tmp=$(mktemp -t dotfiles-terminal) || return
  defaults export com.apple.Terminal "$tmp" 2>/dev/null || { echo "  no Terminal preferences yet"; rm -f "$tmp"; return 1; }
  for key in "Default Window Settings" "Startup Window Settings"; do
    name=$(defaults read com.apple.Terminal "$key" 2>/dev/null) || name=Basic
    [[ $done_names == *":$name:"* ]] && continue
    done_names+="$name:"
    entry=":Window Settings:$name"
    if ! "$pb" -c "Print \"$entry:name\"" "$tmp" >/dev/null 2>&1; then
      echo "  profile '$name': not saved by Terminal yet, skipped"
    elif [[ $("$pb" -c "Print \"$entry:useOptionAsMetaKey\"" "$tmp" 2>/dev/null) == true ]]; then
      echo "  profile '$name': already set"
    else
      "$pb" -c "Delete \"$entry:useOptionAsMetaKey\"" "$tmp" >/dev/null 2>&1
      "$pb" -c "Add \"$entry:useOptionAsMetaKey\" bool true" "$tmp" &&
        { echo "  profile '$name': Option as Meta -> on"; changed=1; }
    fi
  done
  if (( changed )); then
    defaults import com.apple.Terminal "$tmp" && echo "  (restart Terminal to apply)"
  fi
  rm -f "$tmp"
}

# ---- macOS: turn off Mission Control "Switch to Desktop 1 .. 4" (symbolic hotkeys 118 .. 121).
# Bound to Option+1 .. 4 they are swallowed by the OS before the terminal sees them, so tmux
# M-1 .. M-4 do nothing. An id with no entry is the OS default (off) and is left alone.
mac_desktop_switch_keys() {
  local pb=/usr/libexec/PlistBuddy tmp id n changed=0
  local apply=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
  tmp=$(mktemp -t dotfiles-hotkeys) || return
  defaults export com.apple.symbolichotkeys "$tmp" 2>/dev/null || { echo "  already off (no shortcut overrides)"; rm -f "$tmp"; return; }
  for id in 118 119 120 121; do
    n=$(( id - 117 ))
    if [[ $("$pb" -c "Print :AppleSymbolicHotKeys:$id:enabled" "$tmp" 2>/dev/null) == true ]]; then
      "$pb" -c "Set :AppleSymbolicHotKeys:$id:enabled false" "$tmp" &&
        { echo "  Switch to Desktop $n: off"; changed=1; }
    else
      echo "  Switch to Desktop $n: already off"
    fi
  done
  if (( changed )); then
    defaults import com.apple.symbolichotkeys "$tmp" &&
      { [[ -x $apply ]] && "$apply" -u || echo "  (log out to apply)"; }
  fi
  rm -f "$tmp"
}

# Run a macOS setting function, asking first unless -y was given.
mac_setting() {   # label, function
  if (( yes_all )); then
    echo "$1"; "$2"; return
  fi
  read -rp "$1  set? (y/N) " -n 1
  echo
  case $REPLY in
    [Yy]) "$2" ;;
    *)    echo "  skipped" ;;
  esac
}

if [[ $(uname -s) == Darwin ]]; then
  mac_setting "macOS key repeat (KeyRepeat 1.3 / InitialKeyRepeat 25)" mac_key_repeat
  mac_setting "Terminal.app Option as Meta key (default / startup profile)" mac_terminal_option_meta
  mac_setting "Mission Control: Switch to Desktop 1-4 shortcuts off" mac_desktop_switch_keys
fi
