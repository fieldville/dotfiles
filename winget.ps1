# Windows counterpart of `brew bundle`: install everything listed in Wingetfile via winget,
# then the PowerShell modules (psmodule "...") listed there, then the VS Code extensions
# (vscode "...") listed in Brewfile.
#   powershell -ExecutionPolicy Bypass -File .\winget.ps1          # install what is missing
#   powershell -ExecutionPolicy Bypass -File .\winget.ps1 -DryRun  # only show what would be installed
#   powershell -ExecutionPolicy Bypass -File .\winget.ps1 -SkipVscode
param(
  [switch]$DryRun,
  [switch]$SkipVscode
)

$ErrorActionPreference = "Continue"
$root = $PSScriptRoot
Push-Location $root   # code.cmd refuses to start from a UNC cwd (e.g. when launched from WSL)

# Lines look like:  kind "name"   optionally followed by   , cmd: "exe"   and/or   , override: "args"   and/or   , min: "x.y"
function Read-Entries([string]$file, [string]$kind) {
  Get-Content (Join-Path $root $file) | ForEach-Object {
    if ($_ -match "^$kind\s+`"([^`"]+)`"(.*)") {
      $entry = [pscustomobject]@{ Name = $Matches[1]; Cmd = $null; Override = $null; Min = '0.0' }
      foreach ($opt in [regex]::Matches($Matches[2], "(\w+):\s*`"([^`"]+)`"")) {
        switch ($opt.Groups[1].Value) {
          'cmd'      { $entry.Cmd      = $opt.Groups[2].Value }
          'override' { $entry.Override = $opt.Groups[2].Value }
          'min'      { $entry.Min      = $opt.Groups[2].Value }
        }
      }
      $entry
    }
  }
}

# ---- winget ----------------------------------------------------------------
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Error "winget not found. Install 'App Installer' from the Microsoft Store first."
  exit 1
}

$wanted = Read-Entries "Wingetfile" "winget"

# One `winget export` is far faster than `winget list` per package.
$tmp = Join-Path $env:TEMP "winget-installed.json"
winget export -o $tmp --accept-source-agreements *> $null
$installed = @{}
if (Test-Path $tmp) {
  (Get-Content $tmp -Raw | ConvertFrom-Json).Sources |
    ForEach-Object { $_.Packages } |
    ForEach-Object { $installed[$_.PackageIdentifier] = $true }
  Remove-Item $tmp
}

$missing = @($wanted | Where-Object {
  -not $installed[$_.Name] -and -not ($_.Cmd -and (Get-Command $_.Cmd -ErrorAction SilentlyContinue))
})
"winget: $($wanted.Count) listed, $($missing.Count) to install"
foreach ($p in $missing) {
  if ($DryRun) { "  would install $($p.Name)$(if ($p.Override) { " (override: $($p.Override))" })"; continue }
  "  installing $($p.Name)"
  $wingetArgs = @('install', '--id', $p.Name, '-e', '--silent', '--accept-source-agreements', '--accept-package-agreements')
  # --override replaces the installer arguments from the manifest entirely, so the entry
  # itself must ask for a quiet install (e.g. Visual Studio's --quiet --wait --norestart).
  if ($p.Override) { $wingetArgs += @('--override', $p.Override) }
  winget @wingetArgs
  if ($LASTEXITCODE -ne 0) { Write-Warning "  failed: $($p.Name) (exit $LASTEXITCODE)" }
}

# ---- PowerShell modules ----------------------------------------------------
# Installed into the user module dir of the shell running this script. Windows PowerShell 5.1
# cannot see pwsh's dir (pwsh can see 5.1's), so run from Windows PowerShell to cover both,
# or run setup.ps1 in each shell. setup.ps1 reads the same entries.
$modules = @(Read-Entries "Wingetfile" "psmodule")
$missingModules = @($modules | Where-Object {
  $min = [version]$_.Min
  -not (Get-Module -ListAvailable -Name $_.Name | Where-Object { $_.Version -ge $min })
})
"psmodule: $($modules.Count) listed, $($missingModules.Count) to install"
if ($missingModules -and $PSVersionTable.PSVersion.Major -lt 6) {
  # 5.1 defaults to TLS 1.0/1.1, which the PowerShell Gallery no longer accepts.
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
foreach ($m in $missingModules) {
  if ($DryRun) { "  would install $($m.Name)"; continue }
  "  installing $($m.Name)"
  Install-Module -Name $m.Name -MinimumVersion $m.Min -Scope CurrentUser -Force
}

# ---- VS Code extensions ----------------------------------------------------
if (-not $SkipVscode) {
  $code = Get-Command code -ErrorAction SilentlyContinue
  if (-not $code) { $code = Get-Command "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" -ErrorAction SilentlyContinue }
  if ($code) {
    $have = @{}; & $code --list-extensions | ForEach-Object { $have[$_.ToLower()] = $true }
    $exts = Read-Entries "Brewfile" "vscode" | ForEach-Object Name | Where-Object { -not $have[$_.ToLower()] }
    "vscode: $($exts.Count) extensions to install"
    foreach ($e in $exts) {
      if ($DryRun) { "  would install $e"; continue }
      & $code --install-extension $e | Out-Null
    }
  } else { "vscode: 'code' not found, skipping extensions" }
}

Pop-Location
