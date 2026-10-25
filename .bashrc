# ble.sh (Bash Line Editor): zsh-autosuggestions-like inline suggestions from history,
# syntax highlighting and menu completion for bash. Neither apt nor Homebrew package it:
#   git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
#   make -C /tmp/ble.sh install PREFIX=~/.local
# Sourced with --attach=none here and attached at the very end of this file, as its README
# recommends, so everything in between (fzf, zoxide, starship) is set up before it takes
# over the line editor. Settings are in .blerc in this repo. Skipped silently when absent.
if [[ $- == *i* && -f ~/.local/share/blesh/ble.sh ]]; then
  source -- ~/.local/share/blesh/ble.sh --attach=none
fi

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options.
export HISTCONTROL=ignoredups:erasedups

# Append to the history file, don't overwrite it.
shopt -s histappend

# Share history between sessions. Under ble.sh this is `bleopt history_share=1` (.blerc);
# the readline hack below would make ble.sh reload the whole history file at every prompt.
[[ ${BLE_VERSION-} ]] || export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# History size up
export HISTSIZE=100000
export HISTFILESIZE=100000

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export LESS="iSMR"
[[ $- == *i* ]] && bind 'set horizontal-scroll-mode off'

# Prepend extra bin dirs to PATH.
export PATH=/usr/local/bin:$PATH
export PATH=/sbin:/usr/sbin:$PATH
export PATH=~/.local/bin:$PATH

[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.alias ] && . ~/.alias
[ -f ~/.alias.private ] && . ~/.alias.private
# fzf: Ctrl+r history, Ctrl+t files, Alt+c dirs, `**<Tab>` completion. Under ble.sh the
# `bind` calls that `fzf --bash` emits must not be used; its fzf integration modules load
# the same key-bindings.bash / completion.bash from fzf's install dir instead.
if command -v fzf >/dev/null 2>&1; then
  if [[ ${BLE_VERSION-} ]]; then
    ble-import -d integration/fzf-completion
    ble-import -d integration/fzf-key-bindings
  else
    eval "$(fzf --bash)"
  fi
fi
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash --cmd j)"
[ -f ~/.falias ] && source ~/.falias
[ -f ~/.kalias ] && source ~/.kalias
[ -f ~/.dalias ] && source ~/.dalias
[ -f ~/.fieldville/nvim/docker/alias.sh ] && . ~/.fieldville/nvim/docker/alias.sh

[ -r ~/.byobu/prompt ] && . ~/.byobu/prompt #byobu-prompt#

# Set your favorite editor here.
VISUAL=nvim
export VISUAL
EDITOR=nvim
export EDITOR

# starship prompt (keep LAST so it overrides byobu's PS1 above)
# Config is .posh/starship.toml in this repo (shared with .zshrc and the PowerShell
# profile), found via the real location of this file, so no ~/.config/starship.toml
# symlink is needed on a new machine. A STARSHIP_CONFIG already set wins.
if [[ $- == *i* ]] && command -v starship >/dev/null 2>&1; then
  : "${STARSHIP_CONFIG:=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.posh/starship.toml}"
  export STARSHIP_CONFIG
  eval "$(starship init bash)"
fi

# --- added on Ubuntu 26.04 migration
[ -f ~/.cargo/env ] && . ~/.cargo/env
export PATH="$HOME/.local/share/fnm:$PATH"
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)"

# ble.sh: attach last, after everything above has run (see the top of this file).
[[ ! ${BLE_VERSION-} ]] || ble-attach
