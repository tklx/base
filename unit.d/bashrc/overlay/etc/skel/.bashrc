# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoredups:ignorespace
shopt -s histappend

function realpath() {
    f=$@

    if [ -d "$f" ]; then
        base=""
        dir="$f"
    else
        base="/$(basename "$f")"
        dir=$(dirname "$f")
    fi

    dir=$(cd "$dir" && /bin/pwd)
    echo "$dir$base"
}

# prompt path to max 2 levels - best compromise of readability and usefulness
function promptpath() {
    realpwd=$(realpath $PWD)
    realhome=$(realpath $HOME)

    # if we are in the home directory
    if echo $realpwd | grep -q "^$realhome"; then
        path=$(echo $realpwd | sed "s|^$realhome|\~|")
        if [ "$path" = "~" ] || [ "$(dirname "$path")" = "~" ]; then
            echo $path
        else
            echo $(basename $(dirname "$path"))/$(basename "$path")
        fi
        return
    fi

    path_dir=$(dirname $PWD)
    # if our parent dir is a top-level directory, don't mangle it
    if [ $(dirname $path_dir) = "/" ]; then
        echo $PWD
    else
        path_parent=$(basename "$path_dir")
        path_base=$(basename "$PWD")
        echo $path_parent/$path_base
    fi
}

if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto --group-directories-first'
    alias grep='grep --color=auto'
    PS1='\[\033[01;33m\]\u@\h \[\033[01;34m\]$(promptpath)\[\033[00m\]\$ '
else
    alias ls="ls -F"
    PS1='\u@\h $(promptpath)\$ '
fi
