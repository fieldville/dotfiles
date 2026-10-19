Installation:
------------

```
$ git clone git://github.com/fieldville/dotfiles.git ~/.dotfiles
$ cd .dotfiles
$ ./setup.bash
```

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
