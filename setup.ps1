# Windows counterpart of setup.bash: make $PROFILE dot-source the profile in this repo
# so that `git pull` alone picks up changes, and install the PowerShell modules the profile
# needs (psmodule "..." entries in Wingetfile). Run once per shell (Windows PowerShell / pwsh):
# each has its own $PROFILE and its own user module dir (pwsh also searches the Windows
# PowerShell one, the reverse is not true).
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#   pwsh -ExecutionPolicy Bypass -File .\setup.ps1
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
$modules = Get-Content (Join-Path $PSScriptRoot "Wingetfile") | ForEach-Object {
  if ($_ -match "^psmodule\s+`"([^`"]+)`"") { $Matches[1] }
}
$missing = $modules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
if ($missing -and $PSVersionTable.PSVersion.Major -lt 6) {
  # 5.1 defaults to TLS 1.0/1.1, which the PowerShell Gallery no longer accepts.
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
foreach ($m in $modules) {
  if ($m -in $missing) {
    "Installing $m ..."
    Install-Module -Name $m -Scope CurrentUser -Force
    "Installed $m"
  } else {
    "Already installed: $m"
  }
}
