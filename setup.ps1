# Windows counterpart of setup.bash: make $PROFILE dot-source the profile in this repo
# so that `git pull` alone picks up changes. Run once per shell (Windows PowerShell / pwsh),
# since each has its own $PROFILE:
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1

$src  = Join-Path $PSScriptRoot ".posh\PowerShell\Microsoft.PowerShell_profile.ps1"
$line = ". '$src'"

if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -SimpleMatch $line -Quiet)) {
  "Already set up: $PROFILE"
  return
}

if (Test-Path $PROFILE) {
  Copy-Item $PROFILE "$PROFILE.bak" -Force
  "Backed up existing profile to $PROFILE.bak"
}
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE) | Out-Null
Set-Content -Path $PROFILE -Value $line
"Wrote $PROFILE -> $src"
