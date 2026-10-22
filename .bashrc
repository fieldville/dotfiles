# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options.
export HISTCONTROL=ignoredups:erasedups

# Append to the history file, don't overwrite it.
shopt -s histappend

export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

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
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
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
