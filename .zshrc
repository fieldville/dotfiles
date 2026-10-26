# zsh interactive shell: plain zsh + Starship (no oh-my-zsh / zplug).
# Kept in step with .bashrc so bash and zsh behave the same; the alias files
# (.alias, .galias, .falias, .kalias, .dalias) are in this repo too.

# Directory this file really lives in (follows the ~/.zshrc symlink), so repo-local
# files like .posh/starship.toml are found wherever the repo is cloned.
_dotfiles_dir=${${(%):-%N}:A:h}

# --- history (same sizes and dedup behaviour as .bashrc)
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

# --- key bindings. Same as bash (.inputrc): emacs keymap, history
# search by the typed prefix on Ctrl-p/Ctrl-n, Alt-p/Alt-n and Up/Down.
# "bindkey -e" is explicit because zsh would otherwise pick the vi keymap whenever
# EDITOR/VISUAL=nvim is inherited from the environment (e.g. inside byobu).
bindkey -e
# Walk the history lines that start with what has been typed, newest first, and
# leave the cursor at the end of the line (bash's history-search-backward).
# zsh's own history-beginning-search-backward(-end) did this before, but it does
# not reliably stop at the oldest match: when the history file has been read in
# again (fc -R, or share_history re-reading it) the in-memory history can hold the
# same line twice and the walk then starts over from the newest match, and
# zsh-autosuggestions' asynchronous suggestion overwrites $LASTWIDGET, which that
# widget needs to remember the prefix. This widget keeps its own state and shows
# each matching line once, so it stops at the oldest match; Ctrl-n retraces the
# lines shown and then returns to the line that was being typed.
zmodload zsh/parameter
typeset -ga _hps_nums _hps_path
typeset -gA _hps_shown
_history_prefix_search() {
  emulate -L zsh
  local n found=
  # A new search starts whenever the line changed since the previous call;
  # until then the prefix typed at the start of the search is kept.
  if [[ $BUFFER != $_hps_buffer || $HISTNO != $_hps_histno ]]; then
    _hps_prefix=$LBUFFER
    _hps_start=$HISTNO
    _hps_path=()        # history numbers shown so far, newest first
    _hps_shown=()       # their texts, so a duplicated entry is skipped
    _hps_nums=( ${(On)${(k)history[(R)${(b)_hps_prefix}*]}} )  # all matches, newest first
  fi
  if [[ $WIDGET = *-backward ]]; then
    for n in $_hps_nums; do
      (( n < HISTNO )) || continue
      [[ -n $_hps_shown[$history[$n]] || $history[$n] == $BUFFER ]] && continue
      found=$n; break
    done
    [[ -n $found ]] && { _hps_path+=($found); _hps_shown[$history[$found]]=1 }
  else
    n=${_hps_path[(i)$HISTNO]}
    if (( n > $#_hps_path )); then :     # not on a line shown by this search: nothing newer
    elif (( n > 1 )); then found=$_hps_path[n-1]
    else found=$_hps_start               # past the newest match: the line being typed
    fi
  fi
  if [[ -n $found ]]; then
    HISTNO=$found
    CURSOR=$#BUFFER
  fi
  _hps_buffer=$BUFFER _hps_histno=$HISTNO
  [[ -n $found ]]
}
zle -N history-prefix-search-backward _history_prefix_search
zle -N history-prefix-search-forward _history_prefix_search
for k in "^P" "^[p" "^[[A" "^[OA"; do
  bindkey "$k" history-prefix-search-backward
done
for k in "^N" "^[n" "^[[B" "^[OB"; do
  bindkey "$k" history-prefix-search-forward
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
[ -f ~/.galias ] && . ~/.galias
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

# --- added on Ubuntu 26.04 migration (same as .bashrc)
[ -f ~/.cargo/env ] && . ~/.cargo/env
export PATH="$HOME/.local/share/fnm:$PATH"
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"

unset _dotfiles_dir
