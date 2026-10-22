# zsh interactive shell: plain zsh + Starship (no oh-my-zsh / zplug).
# Ported from .dotfiles2/home/.zshrc (the conservative setup) for the home machines
# (WSL, Linux, macOS). The shared alias files (.alias, .falias, .kalias, .dalias) still
# come from ~/.dotfiles2, so clone both repos.

# Directory this file really lives in (follows the ~/.zshrc symlink), so repo-local
# files like .posh/starship.toml are found wherever the repo is cloned.
_dotfiles_dir=${${(%):-%N}:A:h}

# --- history (same sizes and dedup behaviour as .dotfiles2/home/.bashrc)
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups hist_ignore_all_dups hist_ignore_space
setopt share_history inc_append_history extended_history

# --- completion. bashcompinit makes `complete` from .alias/.dalias work in zsh.
# Ubuntu's /etc/zsh/zshrc has already run compinit by the time this file is read;
# running it a second time only costs startup time, so skip it when compdef exists.
autoload -Uz compinit bashcompinit
(( $+functions[compdef] )) || compinit
bashcompinit
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true

# --- key bindings. Same as bash (.dotfiles2/home/.inputrc): emacs keymap, history
# search by the typed prefix on Ctrl-p/Ctrl-n, Alt-p/Alt-n and Up/Down.
# "bindkey -e" is explicit because zsh would otherwise pick the vi keymap whenever
# EDITOR/VISUAL=nvim is inherited from the environment (e.g. inside byobu).
bindkey -e
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
for k in "^P" "^[p" "^[[A" "^[OA"; do
  bindkey "$k" history-beginning-search-backward-end
done
for k in "^N" "^[n" "^[[B" "^[OB"; do
  bindkey "$k" history-beginning-search-forward-end
done
# Alt-k / Alt-j cycle completions forward / backward (menu-complete in .inputrc)
bindkey "^[k" menu-complete
bindkey "^[j" reverse-menu-complete
# completion-ignore-case
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

export LESS="iSMR"

# Prepend extra bin dirs to PATH. (/sbin:/usr/sbin because, unlike bash's
# /etc/profile, Ubuntu's /etc/zsh/zprofile adds nothing to PATH.)
export PATH=/usr/local/bin:$PATH
export PATH=/sbin:/usr/sbin:$PATH
export PATH=~/.local/bin:$PATH

[ -f ~/.alias ] && . ~/.alias
[ -f ~/.alias.private ] && . ~/.alias.private
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh --cmd j)"
[ -f ~/.falias ] && source ~/.falias
[ -f ~/.kalias ] && source ~/.kalias
[ -f ~/.dalias ] && source ~/.dalias
[ -f ~/.fieldville/nvim/docker/alias.sh ] && . ~/.fieldville/nvim/docker/alias.sh

# zsh-autosuggestions / zsh-syntax-highlighting, from Homebrew (macOS / Linuxbrew,
# see Brewfile) or the Ubuntu packages (apt install zsh-autosuggestions
# zsh-syntax-highlighting). Loaded only when present so a fresh machine still starts
# cleanly. Ctrl-Space accepts the suggestion.
for _d in ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share} /usr/share; do
  if [ -f "$_d/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    . "$_d/zsh-autosuggestions/zsh-autosuggestions.zsh"
    bindkey '^ ' autosuggest-accept
    break
  fi
done
# syntax-highlighting must be sourced last among plugins.
for _d in ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share} /usr/share; do
  if [ -f "$_d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    . "$_d/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    break
  fi
done
unset _d

# conda, if installed at the default Anaconda location.
[ -f /opt/anaconda3/etc/profile.d/conda.sh ] && . /opt/anaconda3/etc/profile.d/conda.sh

# Set your favorite editor here.
export VISUAL=nvim
export EDITOR=nvim

# starship prompt (keep LAST). Config is .posh/starship.toml in this repo, the same
# file the PowerShell profile uses, so no ~/.config/starship.toml symlink is needed.
# A STARSHIP_CONFIG already set in the environment wins.
if command -v starship >/dev/null 2>&1; then
  : "${STARSHIP_CONFIG:=$_dotfiles_dir/.posh/starship.toml}"
  export STARSHIP_CONFIG
  eval "$(starship init zsh)"
fi

# --- added on Ubuntu 26.04 migration (same as .dotfiles2/home/.bashrc)
[ -f ~/.cargo/env ] && . ~/.cargo/env
export PATH="$HOME/.local/share/fnm:$PATH"
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

unset _dotfiles_dir
