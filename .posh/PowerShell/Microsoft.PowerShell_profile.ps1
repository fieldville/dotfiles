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

Import-Module PSReadline
Set-PSReadlineOption -EditMode Emacs
#Set-PSReadlineOption -EditMode vi
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key 'Ctrl+p' -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key 'Ctrl+n' -Function HistorySearchForward
#Set-PSReadlineKeyHandler -Key 'Ctrl+r' -Function ReverseSearchHistory
#Set-PSReadlineKeyHandler -Key 'Ctrl+s' -Function ForwardSearchHistory
#Set-PSReadlineKeyHandler -Key 'Ctrl+k' -Function KillLine
#Set-PSReadlineKeyHandler -Key 'Ctrl+u' -Function BackwardKillLine

Import-Module ZLocation
#Import-Module DockerCompletion
#Import-Module posh-docker
Import-Module posh-git
Import-Module oh-my-posh
#Set-PoshPrompt -Theme paradox
#Set-PoshPrompt -Theme robbyrussell
#Set-PoshPrompt -Theme avit
#Set-PoshPrompt -Theme rudolfs-light
#Set-PoshPrompt -Theme rudolfs-dark
Set-PoshPrompt -Theme honukai

Set-Alias g git
Set-Alias vi vim

if (Test-Path alias:rm) { del alias:rm -Force }
if (Test-Path alias:ls) { del alias:ls -Force }

function l { dir $args }
function ll { ls -ltrh $args }
function la { ls -ltrha $args }

function which ($command) {
  Get-command -Name $command -ShowCommandInfo | Format-List -Property Definition
}
function find { busybox find $args }

if (Test-Path alias:gl) { del alias:gl -Force }
if (Test-Path alias:gc) { del alias:gc -Force }
if (Test-Path alias:gp) { del alias:gp -Force }

function gl { git pull $args }
function glr { git pull --rebase }
function gp { git push }
function gd { git diff }
function gss { git status -s $args }
function gc { git commit $args }
function gco { git checkout $args }
function grv { git remote -v }
function gg { git grep $args }
function gori { git config --list --show-origin $args }
function grhh { git reset --hard HEAD }
function gsta { git stash save }
function gstp { git stash pop }
function gca { git commit -v -a $args }

function egrep { egrep --color=auto $args }
function fgrep { fgrep --color=auto $args }
function grep { grep --color --exclude-dir='{.git,.svn}' --exclude=\*.html\* $args }

# for docker
function dco { docker-compose $args }
function dps { docker ps $args }
function ds { docker images; docker ps -a }
function da { docker ps -a }

#Set-Alias docker 'C:\Program Files\Docker\Docker\Resources\bin\docker.exe'
#Set-Alias kubectl 'C:\Program Files\Docker\Docker\Resources\bin\kubectl.exe'

#Set-Location C:\
