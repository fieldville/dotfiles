Installation:
------------

```
$ git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
$ cd .dotfiles
$ ./setup.bash
```

`setup.bash` asks per file whether to link it into `~` (`y` / `n` / `a` = all / `q` = quit).
Use `./setup.bash -y` to link everything without asking.

Windows (PowerShell):
---------------------

```
PS> git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
PS> cd ~/.dotfiles
PS> powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

This makes `$PROFILE` dot-source `.posh/PowerShell/Microsoft.PowerShell_profile.ps1`,
so later changes only need `git pull`. Run it once in each shell you use
(Windows PowerShell and pwsh have separate `$PROFILE`s).

Packages (the winget counterpart of `brew bundle`):

```
PS> powershell -ExecutionPolicy Bypass -File .\winget.ps1          # install what is missing
PS> powershell -ExecutionPolicy Bypass -File .\winget.ps1 -DryRun  # just list it
```

`Wingetfile` lists the Windows-relevant subset of `Brewfile` as winget IDs; VS Code
extensions are read from `Brewfile` itself.
