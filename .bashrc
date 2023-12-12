cd() {
    builtin cd "$@"
}
export HISTTIMEFORMAT="%d/%m/%y %T "
current_hour=$(date +%k)
if [[ "$current_hour" -ge 6 && "$current_hour" -lt 18 ]]; then
    export PS1="\[\e[38;5;33m\][\u@\h \[\e[38;5;39m\]\W\e[m]#\[\e[m\] "
else
    export PS1="\[\e[38;5;249m\][\u@\h \[\e[38;5;33m\]\W\e[m]#\[\e[m\] "
fi
