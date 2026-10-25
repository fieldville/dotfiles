# Proxy template for machines behind a corporate proxy: fill in and uncomment as needed.
# $user = "username"
# $password = "***********"
# $proxyhost = "proxy.co.jp:3128"
# $proxyaddress = "http://$($proxyhost)/"
# $env:http_proxy = "http://$($user):$($password)@$($proxyhost)"
# $env:https_proxy = "http://$($user):$($password)@$($proxyhost)"
# $env:ftp_proxy = "http://$($user):$($password)@$($proxyhost)"
# $password_secure = ConvertTo-SecureString $password -AsPlainText -Force
# $creds = New-Object System.Management.Automation.PSCredential $user, $password_secure
# $proxy = New-Object System.Net.WebProxy $proxyaddress
# $proxy.Credentials = $creds
# [System.Net.WebRequest]::DefaultWebProxy = $proxy
# $env:chocolateyProxyUser = $user
# $env:chocolateyProxyPassword = $password
# $env:chocolateyProxyLocation = $proxyaddress
# # choco config set proxy $proxyhost
# # choco config set proxyUser $user
# # choco config set proxyPassword $password

# Line editing: Emacs keys like bash/readline (.inputrc). Ctrl+p / Ctrl+n search history by
# the typed prefix, Tab cycles through a completion menu.
Import-Module PSReadline
Set-PSReadlineOption -EditMode Emacs
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward

# Inline prediction from history: the PSReadLine counterpart of zsh-autosuggestions. The
# suggestion is shown dimmed after the cursor; Ctrl+f / RightArrow (ForwardChar) take it
# whole when the cursor is at the end of the line, Alt+f (ForwardWord) takes just the next
# word, like zsh's forward-char / forward-word. pwsh (PSReadLine 2.2+) has this on by
# default, Windows PowerShell 5.1 (PSReadLine 2.1.0 on Windows 11) ships it off, so set it
# explicitly for both. PSReadLine refuses (throws) when the console has no VT support or
# output is redirected (`powershell -Command ...` from a script), so check that first.
$psrl = (Get-Module PSReadLine).Version
if ($psrl -lt [version]'2.1') {
  Write-Warning "PSReadLine $psrl has no inline prediction; run: Install-Module PSReadLine -Scope CurrentUser -Force"
} elseif ($Host.UI.SupportsVirtualTerminal -and -not [Console]::IsOutputRedirected) {
  # Plugin predictors need PowerShell 7.2+ (not just PSReadLine 2.2+); 5.1 gets history only.
  $src = if ($PSVersionTable.PSVersion -ge [version]'7.2') { 'HistoryAndPlugin' } else { 'History' }
  Set-PSReadLineOption -PredictionSource $src
  if ($psrl -ge [version]'2.2') { Set-PSReadLineOption -PredictionViewStyle InlineView }   # 2.1.0 is inline-only
  Set-PSReadLineKeyHandler -Chord 'Ctrl+f', 'RightArrow' -Function ForwardChar
  Set-PSReadLineKeyHandler -Chord 'Alt+f' -Function ForwardWord
}

# Ctrl+x, Ctrl+e: edit the current command line in $env:EDITOR (like bash's edit-and-execute-command).
# Useful for pasting / editing multi-line scriptlets; the buffer is replaced on save & quit.
# NOTE: ViEditVisually resolves $env:EDITOR via Get-Command as a single application with no
# arguments, so e.g. 'code --wait' does not work; nvim blocks until exit and works as-is.
if (-not $env:EDITOR) { $env:EDITOR = 'nvim' }
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+e' -Function ViEditVisually

# fzf via PSFzf (PowerShell counterpart of `eval "$(fzf --bash)"` in .bashrc):
# Ctrl+r = fuzzy history search (replaces ReverseSearchHistory),
# Ctrl+t = fuzzy file-path picker (replaces Emacs SwapCharacters).
# Install: `winget install junegunn.fzf` and `Install-Module PSFzf -Scope CurrentUser`.
# NOTE: Windows PowerShell 5.1 and pwsh use separate module dirs
# (Documents\WindowsPowerShell\Modules vs Documents\PowerShell\Modules), so run
# Install-Module from BOTH shells. Skipped silently when either piece is missing,
# so a fresh machine still starts cleanly with PSReadLine's default bindings.
if ((Get-Command fzf -ErrorAction Ignore) -and (Get-Module -ListAvailable PSFzf)) {
  Import-Module PSFzf
  Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# fzf helper functions (fkill, fbr, fco, fshow, gadd, fstash, fda, ...) and the FZF_*
# defaults: counterpart of `source ~/.falias` in .bashrc, see falias.ps1.
# Needs fd / rg (bat optional) for the defaults.
if (Get-Command fzf -ErrorAction Ignore) {
  . (Join-Path $PSScriptRoot 'falias.ps1')
}

# posh-git: git tab completion only, the prompt itself is Starship (below, so it wins).
# Optional: `Install-Module posh-git -Scope CurrentUser`, skipped silently when missing.
if (Get-Module -ListAvailable posh-git) {
  Import-Module posh-git
}

# Starship prompt (https://starship.rs). Install: `winget install Starship.Starship`. The
# default preset uses Nerd Font glyphs, so also install one and select it in the terminal,
# e.g. `winget install DEVCOM.JetBrainsMonoNerdFont`.
# Config: .posh/starship.toml in this repo (shared with .bashrc), pointed to via
# $env:STARSHIP_CONFIG so no symlink into $env:USERPROFILE\.config is needed; a value already
# set elsewhere wins. Skipped silently when starship is missing, so a fresh machine still
# starts cleanly with the default prompt.
if (Get-Command starship -ErrorAction Ignore) {
  if (-not $env:STARSHIP_CONFIG) {
    $env:STARSHIP_CONFIG = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\starship.toml'))
  }
  Invoke-Expression (&starship init powershell)
}

# tig config: .tigrc in this repo (vim-like g/G to first/last line, custom binds).
# tig reads $TIGRC_USER instead of ~/.tigrc, so no symlink is needed; forward slashes keep
# the MSYS2 build shipped with Git for Windows happy. A value already set elsewhere wins.
if (-not $env:TIGRC_USER) {
  $env:TIGRC_USER = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\.tigrc')) -replace '\\', '/'
}

# tig binary: there is no winget/scoop package, but Git for Windows ships tig.exe (MSYS2 build)
# in <git root>\usr\bin, which is deliberately NOT on PATH (it also holds find/sort/...).
# Locate it through `git --exec-path` (<root>\{mingw64,ucrt64}\libexec\git-core) so this works
# for both the scoop and the winget (C:\Program Files\Git) installs, and expose usr\bin only
# for the duration of the tig process so the `!sh -c ...` binds in .tigrc work.
# A tig already on PATH (e.g. a hand-installed one) wins, nothing is shadowed then.
if (-not (Get-Command tig -CommandType Application -ErrorAction Ignore)) {
  function tig {
    $execPath = git --exec-path 2>$null
    if (-not $execPath) { Write-Error "tig: git not found"; return }
    $gitRoot = Split-Path (Split-Path (Split-Path $execPath -Parent) -Parent) -Parent
    $usrBin  = Join-Path $gitRoot 'usr\bin'
    $exe     = Join-Path $usrBin 'tig.exe'
    if (-not (Test-Path $exe)) { Write-Error "tig: not found at $exe (is Git for Windows installed?)"; return }

    $oldPath = $env:PATH
    try {
      $env:PATH = "$usrBin;$env:PATH"
      & $exe @args
    } finally {
      $env:PATH = $oldPath
    }
  }
}

# editor: mirrors `alias vi=nvim` / `view='nvim -R'` / `vimdiff='nvim -d'` in .alias.
# Set-Alias cannot carry arguments, so `view` and `vimdiff` are functions.
Set-Alias vi nvim
function view { nvim -R @args }
function vimdiff { nvim -d @args }

# rm / find: Unix semantics via busybox (`winget install frippery.busybox-w32`), so `rm -rf x`
# and `find . -name '*.log'` work as in bash. PowerShell resolves aliases before functions,
# so the built-in rm alias (Remove-Item) has to go first or the function never runs.
# fd is the usual day-to-day tool; `find` is for muscle memory and copy-pasted one-liners.
if (Test-Path alias:rm) { Remove-Item alias:rm -Force }
function rm { busybox rm @args }
function find { busybox find @args }

# cd -: back to the previous directory, as in bash. pwsh 6.2+ has this built in
# (Set-Location keeps a location history, `cd -` goes back and `cd +` forward), Windows
# PowerShell 5.1 does not, so it gets a wrapper that remembers one previous directory in
# $OLDPWD and toggles like bash. Plain `cd` goes to $HOME (bash/pwsh behaviour; the 5.1
# alias would stay put). Same alias-before-function rule as rm above.
if ($PSVersionTable.PSVersion -lt [version]'6.2') {
  if (Test-Path alias:cd) { Remove-Item alias:cd -Force }
  function cd ([string]$Path) {
    $prev = $PWD.Path
    if ($Path -eq '-') {
      if (-not $global:OLDPWD) { Write-Error 'OLDPWD not set'; return }
      Set-Location -LiteralPath $global:OLDPWD -ErrorAction Stop
    } elseif ($Path) {
      Set-Location $Path -ErrorAction Stop
    } else {
      Set-Location $HOME -ErrorAction Stop
    }
    $global:OLDPWD = $prev
  }
}

# ls / l / ll / la: `ls` stays the built-in alias for Get-ChildItem. l/ll/la mirror .alias
# (l='ls', ll='ls -ltrh', la='ll -A') in Get-ChildItem terms: `-ltr` = sort by mtime, newest last;
# `-A` = -Force (hidden/system files; PowerShell never lists . and ..). Set-Alias cannot
# carry arguments, so these have to be functions.
# `-h` has no Get-ChildItem equivalent, so ll/la render their own table with a Size column
# (4.0K, 12K, 1.5M ... like GNU ls) when they are the last command in the pipeline. When
# something is piped after them (`ll | Where-Object ...`) they emit plain FileSystemInfo
# objects instead, so filtering/sorting keeps working. Note `$x = ll` captures the table.
function ConvertTo-HumanSize ([long]$Bytes) {
  if ($Bytes -lt 1024) { return "$Bytes" }
  $v = [double]$Bytes; $i = -1
  foreach ($u in 'K', 'M', 'G', 'T', 'P') { $v /= 1024; $i++; if ($v -lt 1024) { break } }
  $fmt = if ($v -lt 10) { '{0:0.0}{1}' } else { '{0:0}{1}' }
  [string]::Format([cultureinfo]::InvariantCulture, $fmt, $v, ('K', 'M', 'G', 'T', 'P')[$i])
}

# Name colouring as the default Get-ChildItem view does it ($PSStyle.FileInfo, pwsh 7.2+);
# Windows PowerShell 5.1 has no $PSStyle and gets plain names.
function Format-LsName ($Item) {
  if (-not $PSStyle) { return $Item.Name }
  $fi = $PSStyle.FileInfo
  $color =
    if ($Item.PSIsContainer) { $fi.Directory }
    elseif ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $fi.SymbolicLink }
    elseif ($fi.Extension.ContainsKey($Item.Extension)) { $fi.Extension[$Item.Extension] }
    elseif (($env:PATHEXT -split ';') -contains $Item.Extension) { $fi.Executable }
    else { '' }
  if ($color) { "$color$($Item.Name)$($PSStyle.Reset)" } else { $Item.Name }
}

$LsLongColumns = @(
  'Mode', 'LastWriteTime',
  @{ Label = 'Size'; Align = 'Right'; Expression = { if ($_.PSIsContainer) { '' } else { ConvertTo-HumanSize $_.Length } } },
  @{ Label = 'Name'; Expression = { Format-LsName $_ } }
)

function l { Get-ChildItem @args }
function ll {
  $items = Get-ChildItem @args | Sort-Object LastWriteTime
  if ($MyInvocation.PipelineLength -eq $MyInvocation.PipelinePosition) { $items | Format-Table $LsLongColumns } else { $items }
}
function la {
  $items = Get-ChildItem -Force @args | Sort-Object LastWriteTime
  if ($MyInvocation.PipelineLength -eq $MyInvocation.PipelinePosition) { $items | Format-Table $LsLongColumns } else { $items }
}

# which: show where a command resolves to (alias, function, cmdlet or executable path).
function which ($command) {
  Get-command -Name $command -ShowCommandInfo | Format-List -Property Definition
}

# Git aliases (g, gst, gco, gl, gp, gg, ...): counterpart of `source ~/.galias` in
# .bashrc, see galias.ps1.
. (Join-Path $PSScriptRoot 'galias.ps1')

function egrep { egrep --color=auto $args }
function fgrep { fgrep --color=auto $args }
function grep { grep --color --exclude-dir='{.git,.svn}' --exclude=\*.html\* $args }

# docker: the everyday subset of .dalias (dco, dps, ds, da).
function dco { docker compose @args }
function dps { docker container ls @args }
function ds { docker images; docker ps -a }
function da { docker ps -a }

# zoxide as `j` / `ji` (interactive via fzf): PowerShell counterpart of
# `eval "$(zoxide init bash --cmd j)"` in .bashrc. Install: `winget install ajeetdsouza.zoxide`.
# Kept at the end of the profile: on Windows PowerShell 5.1 zoxide hooks the prompt
# function, so it has to run after Starship has defined it. Skipped silently when missing.
if (Get-Command zoxide -ErrorAction Ignore) {
  Invoke-Expression (& { (zoxide init powershell --cmd j | Out-String) })
}
