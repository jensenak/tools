# shellcheck disable=SC1090,1091
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

[ -z "$PS1" ] && return

_done() {
	if [[ $1 -eq 0 ]]; then
		printf "[\033[0;32m done \033[0m]\n"
	else
		printf "[\033[0;31m failed \033[0m]\n"
	fi
}

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	source "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

HISTTIMEFORMAT='%F %T '
HISTFILESIZE=-1
HISTSIZE=-1
HISTCONTROL=ignoredups
HISTIGNORE='?:??'
shopt -s histappend
shopt -s cmdhist
shopt -s lithist

source /usr/local/etc/bash_completion
export GIT_PS1_SHOWDIRTYSTATE=true

printf "Loading env vars ... "
#ENVIRONMENT VARS I WANT SET
export PROMPT_COMMAND='getPrompt'
#'history -a; history -c; history -r; getPrompt'

LSCOLORS='exgxHxDxCxaDedecgcEhEa'
export LSCOLORS
export GOPATH=/Users/akj/go
export PATH="/Users/akj/gbin:$PATH:/usr/local/opt/go/libexec/bin"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/share/man:/usr/local/share/man:/usr/X11/share/man"
export shoveDir=/tmp/shove
export HOMEBREW_GITHUB_API_TOKEN=384a0c1ddadf28de8aad62a812b6efcbc8e5fc18
export GREP_COLORS='1;33;44'
_done $?


printf "Dynamic files: \n"
#Source everything in profile.d
INDENT=$(echo -e "  \xe2\x86\xb3")
if [ -d ~/profile.d ]; then
	for i in ~/profile.d/*.sh; do
		if [ -r "$i" ]; then
            # shellcheck disable=SC2086
			printf "%s %s ... " "$INDENT" "$(basename $i)"
            shellcheck -s bash "$i" > /dev/null
            if [ $? -ne 0 ]
            then
                _done 1
            else
			    source "$i"
			    _done $?
            fi
		fi
	done
fi

#BASH PROMPT SECTION
printf "\033[0mSetting aliases ..."
#ALIAS SECTION
alias bs='edit_profile'
alias retry='edit_profile true'
alias cleanup='clean_profiles'
alias undo='undo_profile_change'
alias lsp='list_profiles'
alias sb='. ~/.profile'
alias bp='vi ~/profile.d; . ~/.profile'
alias pshs='python -m SimpleHTTPServer 8585'
alias da='deactivate'
alias ls='ls --color=always'
alias ll='ls -lah'
alias lg='ls -lah | grep'
alias lsi='~/tools/lsi.sh'
alias icat='~/tools/imgcat.sh'
alias grep='grep --color=always'
_done $?
#FUNCTIONS FOR FUN AND AWESOMENESS

# Edits this file, but performs shell check before sourcing it again
clean_profiles() {
    find ~/tmp/ -type f -delete
}

undo_profile_change() {
    cp ~/.profile ~/.profile.redo
    cp ~/.profile.bak ~/.profile
}

edit_profile() {
    if [ "$1" ]
    then
        profileName=$(_retry_profile)
    else
        profileName=$(_copy_profile)
    fi
    _edit_profile "$profileName"
}

list_profiles() {
    if [ -d ~/tmp ]
    then
        ls -1 ~/tmp
    fi
    if [ -f ~/.profile.redo ]
    then
        printf ".profile.redo exists from a rollback"
    fi
    if [ -f ~/.profile.bak ]
    then
        printf ".profile.bak exists"
    fi
}

_copy_profile() {
    if [ ! -d ~/tmp ]
    then
        mkdir ~/tmp
    fi
    # profile name contains date and time + .sh for syntax highlighting
    profileName="$HOME/tmp/profile-$(date +%Y%m%d%H%M%S).sh"
    cp ~/.profile "$profileName"
    printf "%s" "$profileName"
}

_retry_profile() {
    PS3="Select a profile copy to start editing: "
    select profileName in ~/tmp/*
    do
        printf "%s" "$profileName"
        break
    done
}

_edit_profile() {
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)
    profileName=$1
    if [ ! -e "$profileName" ]
    then
        printf "%s Could not find tmp file '%s' for editing %s" "$RED" "$profileName" "$RESET"
    else
        vi "$profileName"
        shellcheck -s bash "$profileName"
        if [ $? -ne 0 ]
        then
            printf "%s ## Your edits have introduced errors, not sourcing file ## %s\n" "$RED" "$RESET"
            printf "The following commands may help you:\n lsp -> list profile versions\n retry -> edit a profile version\n undo -> revert to the profile backup \n cleanup -> discard profile versions"
        else
            printf "%s ## Your edits look good, sourcing file ## %s\n" "$GREEN" "$RESET"
            cp ~/.profile ~/.profile.bak
            cp "$profileName" ~/.profile
            source ~/.profile
            rm "$profileName"
        fi 
    fi
}

chup() {
    if [[ -z $1 ]]
    then
        cd ..
    else
        p=./
        for (( i=0; i<${#1}; i++ ))
        do
            p=${p}../ 
        done
        cd "$p" || exit 1
    fi
}

cm() {
    mkdir -p "$1"
    cd "$1" || exit 1
}

venv() {
    b=$(basename "$PWD")
    venv_path=~/virtual_envs/
    if [[ -z $1 ]]
    then
        if [[ -d ~/$venv_path/$b ]]
        then
            source "$HOME/$venv_path/$b/bin/activate"
        else
            printf "Could not find virtual env for %s\n" "$b"
        fi
    else
        if [[ $1 == "2" || $1 == "3" ]]
        then
            virtualenv -p "python$1" "$HOME/$venv_path/$b"
            source "$HOME/$venv_path/$b/bin/activate"
        else
            printf "Python version must be 2 or 3"
        fi
    fi
}

#pull all subdirectories of the current (or specified) dir
# usage: pullall [any path]
pullall() {
    PWDsave=$PWD
    if [ -n "$1" ]
    then
        cd "$1" || exit 1
    fi
    for dir in * 
    do
        if [ -d "$dir" ]
        then
            cd "$dir" || exit 1
            git pull
            cd .. || exit 1
        fi
    done
    cd "$PWDsave" || exit 1
}

#Colorize stderr
# usage: colorize COMMAND [ARGS...]
colorize()(set -o pipefail; "$@" 2>&1>&3|sed $'s/.*/\e[1;31m&\e[m/'>&2)3>&1
