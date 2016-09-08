# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend

# max 2 level - best compromise of readability and usefulness
function promptpath() {
    path="${PWD/#$HOME/\~}"
    if [ $(echo "${path:1}" | tr -d -c / | wc -c) -gt 1 ]; then
        path=$(echo "$path" | rev | cut -d/ -f-2 | rev)
    fi
    echo "$path"
}

if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto --group-directories-first'
    alias grep='grep --color=auto'
    PS1='\[\033[01;33m\]\u@\h \[\033[01;34m\]$(promptpath)\[\033[00m\]\$ '
else
    alias ls="ls -F --group-directories-first"
    PS1='\u@\h $(promptpath)\$ '
fi
