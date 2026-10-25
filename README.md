Installation:
------------

```
$ git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
$ cd .dotfiles
$ ./setup.bash
```

`setup.bash` asks per file whether to link it into `~` (`y` / `n` / `a` = all / `q` = quit).
Use `./setup.bash -y` to link everything without asking.

VS Code:
--------

`vscode/` holds the user-level `settings.json` and `keybindings.json` (and `snippets/` if you
add one). `setup.bash` / `setup.ps1` symlink each of them into VS Code's user settings
directory, so `git pull` alone updates the running editor (VS Code watches those files; no
restart needed) and changes made from the Settings UI land in this repo as a diff to commit.
Extensions are the `vscode "..."` lines in `Brewfile`, installed by `brew bundle` / `winget.ps1`.

| OS                        | linked into                                              |
|---------------------------|----------------------------------------------------------|
| macOS                     | `~/Library/Application Support/Code/User`                |
| Linux                     | `~/.config/Code/User`                                    |
| Windows                   | `%APPDATA%\Code\User`                                    |
| Windows, portable (scoop) | `<install>\data\user-data\User` (detected via `code` on PATH) |

WSL is skipped: VS Code there is the Windows one and reads the Windows-side settings.
On Windows, file symlinks need Developer Mode (Settings > System > For developers) or an
elevated shell; otherwise `setup.ps1` copies the two files and warns, and re-running it
with either in place replaces the copies with links (`snippets/` is a junction and needs
neither). OS-specific keys (`*.windows`, `*.osx`, `*.linux`) are ignored on other OSes, so
one shared `settings.json` is enough; machine-specific values such as a proxy belong in
`HTTP_PROXY` rather than in the file. The folder is deliberately not named `.vscode`, which
VS Code would treat as workspace settings when this repo is opened as a folder.

bash: ble.sh
------------

`.bashrc` loads [ble.sh](https://github.com/akinomyoga/ble.sh) (Bash Line Editor) when it
is installed, which gives bash the zsh-autosuggestions-style inline suggestions from
history, syntax highlighting and menu completion; `.blerc` in this repo holds its settings.
It is not packaged by apt or Homebrew, so install it from source (no root needed):

```
$ git clone --recursive --depth 1 https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh
$ make -C /tmp/ble.sh install PREFIX=~/.local      # -> ~/.local/share/blesh/ble.sh
```

Accepting a suggestion: `Ctrl+F` / `Right` / `End` take all of it (cursor at end of line),
`Alt+F` the next word, `Shift+Enter` all of it from anywhere. fzf's `Ctrl+R` / `Ctrl+T` /
`Alt+C` are loaded through ble.sh's own fzf integration, and `.inputrc` is still honoured.
Without ble.sh everything falls back to plain readline + `fzf --bash`.

zsh:
----

`.zshrc` / `.zprofile` are the zsh counterpart of `.bashrc` / `.profile` (plain zsh +
Starship, no oh-my-zsh). Both shells source the same alias files (`.alias`, `.galias`,
`.falias`, `.kalias`, `.dalias`) and Starship reads `.posh/starship.toml`, all from this repo, so
this repo alone is enough on a home machine. zsh-autosuggestions /
zsh-syntax-highlighting are optional and picked up from Homebrew or the Ubuntu
packages when installed.

```
$ brew bundle                                                          # macOS: zsh plugins are in Brewfile
$ sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting     # Ubuntu / WSL
$ ./setup.bash                                                         # links .zshrc and .zprofile among the rest
$ chsh -s "$(command -v zsh)"
```

byobu / tmux start `$SHELL` (see `.byobu/shell-expand.tmux` and `.tmux.conf.osx`),
so new windows open zsh once `chsh` has run and you have logged in again.

Windows (PowerShell):
---------------------

```
PS> git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
PS> cd ~/.dotfiles
PS> powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

This makes `$PROFILE` dot-source `.posh/PowerShell/Microsoft.PowerShell_profile.ps1`,
so later changes only need `git pull`, and installs the PowerShell modules the profile
needs (`psmodule` entries in `Wingetfile`: PSFzf, posh-git). Run it once in each shell
you use (Windows PowerShell and pwsh have separate `$PROFILE`s and module directories).

Packages (the winget counterpart of `brew bundle`):

```
PS> powershell -ExecutionPolicy Bypass -File .\winget.ps1          # install what is missing
PS> powershell -ExecutionPolicy Bypass -File .\winget.ps1 -DryRun  # just list it
```

`Wingetfile` lists the Windows-relevant subset of `Brewfile` as winget IDs plus the
PowerShell Gallery modules (`psmodule`); VS Code extensions are read from `Brewfile` itself.
An entry's `override: "..."` is passed through to the package's own installer (used for
Visual Studio Community, which otherwise installs with no workloads). Visual Studio needs
elevation, so expect a UAC prompt during that step.

The profile mirrors `.alias` (`l`/`ll`/`la`, `vi`/`view`/`vimdiff` on nvim) and dot-sources
`.posh/PowerShell/galias.ps1`, the PowerShell port of the git aliases in `.galias` (`g`,
`gst`, `gco`, `gl`, `gp`, `gg`, ...), and `.posh/PowerShell/falias.ps1`, the port of the
fzf helpers in `.falias` (`fco`, `fkill`, `fshow`, `gadd`, `fstash`, `fda`, ...), the latter
only when fzf is on PATH, and `.posh/PowerShell/dalias.ps1`, the port of the docker aliases
in `.dalias` (`d`, `dco`, `dps`, `dex`, `dcu`, `dcl`, ...), and `.posh/PowerShell/kalias.ps1`,
generated from the kubectl aliases in `.kalias` (`k`, `kg`, `kgpo`, `kd`, `klo`, ...) and
loaded only when kubectl is on PATH. One alias file per tool, so a change to the git
aliases shows up as a diff of `.galias` / `galias.ps1` alone.

tig: the profile points `$TIGRC_USER` at `.tigrc` in this repo (a value already set
wins), so no symlink is needed on Windows. There is no winget package, but Git for
Windows bundles `tig.exe` in `usr\bin` (not on PATH); when no `tig` is on PATH the
profile defines a `tig` function that runs that copy.
