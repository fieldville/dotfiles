# byobu's default is: set -g default-command 'exec $SHELL'
# Single quotes leave "$SHELL" unexpanded, and tmux may then use that literal
# string as the window name (e.g. "3:\\$SHELL-"). Double quotes make tmux
# expand $SHELL while parsing the config, so the fallback name becomes "bash".
#
# Kept outside .tmux.conf on purpose: byobu skips byobu-shell for the first
# window when it finds the string "default-command" in .tmux.conf.
set -g default-command "exec $SHELL"
