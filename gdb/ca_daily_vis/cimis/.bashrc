test -r ~/.alias && . ~/.alias
PS1='GRASS 6.4.1 (ca_daily_vis):\w > '
PROMPT_COMMAND="'/usr/lib64/grass-6.4.1/etc/prompt.sh'"
export PATH="/usr/lib64/grass-6.4.1/bin:/usr/lib64/grass-6.4.1/scripts:/apps/cimis/grass/bin:/apps/cimis/grass/scripts:/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/apps/cimis/bin"
export HOME="/apps/cimis"
export GRASS_SHELL_PID=$$
trap "echo \"GUI issued an exit\"; exit" SIGQUIT
