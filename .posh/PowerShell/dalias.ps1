# Docker aliases: PowerShell counterpart of .dalias (bash/zsh) in this repo, dot-sourced from
# Microsoft.PowerShell_profile.ps1 like galias.ps1 / falias.ps1. Keep the two in sync when
# adding one. None of the names collide with a built-in alias, so nothing has to be removed
# first. The bash-completion wrapper in .dalias has no PowerShell equivalent and is omitted.

Set-Alias d docker
function dco { docker compose @args }
function dc { docker compose @args }

# containers
function dps { docker container ls @args }
function dpa { docker container ls --all @args }
function dl { docker container ls --latest --quiet }
function ds { docker images; docker ps -a }
function da { docker ps -a }
function dcnt { docker container @args }
# Stop every running container, wherever you are and without knowing a name
function dsa { $ids = docker container ls -q; if ($ids) { docker stop $ids } }

# images
function di { docker image ls @args }
function dia { docker image ls --all @args }
function dimg { docker image @args }

# compose stack in the current directory: up / up --build / stop / down / restart / logs
# (`dcl php` shows the logs of the php service only)
function dcu { docker compose up -d @args }
function dcub { docker compose up -d --build @args }
function dcs { docker compose stop @args }
function dcd { docker compose down @args }
function dcr { docker compose restart @args }
function dcl { docker compose logs @args }

# run
function drd { docker container run --detach --publish-all @args }
function dri { docker container run --interactive --tty --publish-all @args }
function drun { docker container run --rm -d @args }
function drunit { docker container run --rm -it @args }

# IP address of a container
function dip { docker container inspect --format '{{ .NetworkSettings.IPAddress }}' @args }
function dock-ip { docker inspect --format '{{ .NetworkSettings.IPAddress }}' @args }

# exec into a container: `dex <container> bash`
function dex { docker exec -i -t --privileged @args }

# the most recently started running container, and exec / stop on it
function dcur { docker container ls -f status=running -l -q }
function dexec { $c = dcur; if ($c) { docker container exec -it $c @args } else { Write-Error 'dexec: no running container' } }
function dstop { $c = dcur; if ($c) { docker container stop $c } else { Write-Error 'dstop: no running container' } }

# remove all containers / all images / everything by force / dangling data
function drm { $ids = docker container ls --all --quiet; if ($ids) { docker container rm $ids } }
function drmi { $ids = docker image ls -q; if ($ids) { docker image rm $ids } }
function dclean { $ids = docker container ls --all --quiet; if ($ids) { docker container kill $ids }; drm; drmi }
function dprn { docker system prune @args }

# list the docker aliases defined here (dalias) or just the compose ones (dcalias)
function dalias { Get-ChildItem function: | Where-Object { $_.Definition -match 'docker' } | Sort-Object Name | Format-Table Name, Definition -AutoSize }
function dcalias { Get-ChildItem function: | Where-Object { $_.Definition -match 'docker compose' } | Sort-Object Name | Format-Table Name, Definition -AutoSize }
