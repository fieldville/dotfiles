# Windows counterpart of setup.bash: make $PROFILE dot-source the profile in this repo
# so that `git pull` alone picks up changes, install the PowerShell modules the profile
# needs (psmodule "..." entries in Wingetfile), and link vscode\* into the VS Code user
# settings dir. Run once per shell (Windows PowerShell / pwsh): each has its own $PROFILE
# and its own user module dir (pwsh also searches the Windows PowerShell one, the reverse
# is not true).
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   pwsh -ExecutionPolicy Bypass -File .\setup.ps1
# File symlinks need Developer Mode (Settings > System > For developers) or an elevated
# shell; without either the VS Code files are copied instead and a warning says so.
# CLI tools (fzf, zoxide, starship, ...) are installed separately by winget.ps1.

# $PROFILE lives under OneDrive\Documents and is synced between machines whose user names
# differ, so the line must resolve $HOME at load time instead of baking in an absolute path.
# This assumes the repo is cloned to ~/.dotfiles on every machine (as setup.bash does).
$src  = Join-Path $PSScriptRoot ".posh\PowerShell\Microsoft.PowerShell_profile.ps1"
$rel  = ".dotfiles\.posh\PowerShell\Microsoft.PowerShell_profile.ps1"
if ($src -ne (Join-Path $HOME $rel)) {
  Write-Warning "This repo is at $PSScriptRoot, but `$PROFILE will look for it at ~\.dotfiles. Move/clone it there."
}
$line = ". (Join-Path `$HOME '$rel')"

if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -SimpleMatch $line -Quiet)) {
  "Already set up: $PROFILE"
} else {
  if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.bak" -Force
    "Backed up existing profile to $PROFILE.bak"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
  Set-Content -Path $PROFILE -Value $line
  "Wrote $PROFILE -> $src"
}

# ---- PowerShell modules (same list as winget.ps1) --------------------------
# psmodule "Name"[, min: "x.y"]. A module below its minimum version counts as missing:
# Windows PowerShell 5.1 ships PSReadLine 2.0.0, which would otherwise pass as "installed".
$modules = Get-Content (Join-Path $PSScriptRoot "Wingetfile") | ForEach-Object {
  if ($_ -match "^psmodule\s+`"([^`"]+)`"(.*)") {
    $min = if ($Matches[2] -match "min:\s*`"([^`"]+)`"") { $Matches[1] } else { '0.0' }
    @{ Name = $Matches[1]; Min = $min }
  }
}
$missing = @($modules | Where-Object {
  $min = [version]$_.Min
  -not (Get-Module -ListAvailable -Name $_.Name | Where-Object { $_.Version -ge $min })
})
if ($missing -and $PSVersionTable.PSVersion.Major -lt 6) {
  # 5.1 defaults to TLS 1.0/1.1, which the PowerShell Gallery no longer accepts.
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
foreach ($m in $modules) {
  if ($m -in $missing) {
    "Installing $($m.Name) ..."
    Install-Module -Name $m.Name -MinimumVersion $m.Min -Scope CurrentUser -Force
    "Installed $($m.Name)"
  } else {
    "Already installed: $($m.Name)"
  }
}

# ---- VS Code: link vscode\* into the user settings dir ---------------------
# VS Code watches settings.json / keybindings.json / snippets, so once they are links into
# this repo `git pull` alone updates the running editor, and edits made in VS Code land in
# the repo. A portable install (scoop puts VS Code in portable mode) keeps its user data in
# <install>\data\user-data\User instead of %APPDATA%\Code\User.
function Get-VSCodeUserDir {
  $code = Get-Command code -ErrorAction SilentlyContinue
  if ($code) {
    $install = Split-Path (Split-Path $code.Source)   # ...\bin\code.cmd -> install dir
    if (Test-Path (Join-Path $install "data")) { return Join-Path $install "data\user-data\User" }
  }
  Join-Path $env:APPDATA "Code\User"
}

function Link-VSCodeItem([string]$src, [string]$dst) {
  $isDir = Test-Path $src -PathType Container
  $existing = Get-Item $dst -Force -ErrorAction SilentlyContinue
  if ($existing -and $existing.LinkType -and ("$($existing.Target)" -eq $src)) {
    "Already linked: $dst"; return
  }
  if ($existing) {
    if ($existing.LinkType) {
      $existing.Delete()   # removes the link itself, never its target
    } elseif (-not $isDir -and (Get-FileHash $dst).Hash -eq (Get-FileHash $src).Hash) {
      Remove-Item $dst     # a copy left by an earlier run: nothing to back up
    } else {
      $bak = "$dst.bak"
      if (Test-Path $bak) { $bak = "$dst.$(Get-Date -Format yyyyMMddHHmmss).bak" }   # keep earlier backups
      Move-Item $dst $bak
      "Backed up $dst -> $bak"
    }
  }
  if ($isDir) {
    # Junctions need no privilege, unlike directory symlinks.
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    "Linked $dst -> $src"
    return
  }
  try {
    New-Item -ItemType SymbolicLink -Path $dst -Target $src -ErrorAction Stop | Out-Null
    "Linked $dst -> $src"
  } catch {
    Copy-Item $src $dst
    Write-Warning "Copied $dst (could not symlink: $($_.Exception.Message.Trim())). It will NOT follow git pull; enable Developer Mode or re-run setup.ps1 elevated to replace the copy with a link."
  }
}

$userDir = Get-VSCodeUserDir
New-Item -ItemType Directory -Force -Path $userDir | Out-Null
"VS Code user dir: $userDir"
Get-ChildItem (Join-Path $PSScriptRoot "vscode") | ForEach-Object {
  Link-VSCodeItem $_.FullName (Join-Path $userDir $_.Name)
}
