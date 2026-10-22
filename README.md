Installation:
------------

```
$ git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
$ cd .dotfiles
$ ./setup.bash
```

`setup.bash` asks per file whether to link it into `~` (`y` / `n` / `a` = all / `q` = quit).
Use `./setup.bash -y` to link everything without asking.

zsh:
----

`.zshrc` / `.zprofile` are the zsh counterpart of `.dotfiles2/home/.bashrc` / `.profile`
(plain zsh + Starship, no oh-my-zsh). They still source the shared alias files
(`.alias`, `.falias`, `.kalias`, `.dalias`) from `~/.dotfiles2`, so clone both repos.
Starship reads `.posh/starship.toml` from this repo, the same file the PowerShell
profile uses. zsh-autosuggestions / zsh-syntax-highlighting are optional and picked up
from Homebrew or the Ubuntu packages when installed.

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

tig: there is no winget package, but Git for Windows bundles `tig.exe` in `usr\bin`
(not on PATH). The profile defines a `tig` function that runs it and points
`$TIGRC_USER` at `~\.tigrc` or `~\.dotfiles2\home\.tigrc` (whichever exists), so
clone [dotfiles2](https://github.com/fieldville/dotfiles2) to `~\.dotfiles2` to get
the shared `.tigrc` without a symlink.
