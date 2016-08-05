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
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
printf "Loading env vars ..."
#ENVIRONMENT VARS I WANT SET
export PROMPT_COMMAND='history -a; history -c; history -r; getPrompt'

export GOPATH=/home/ARBFUND/ajensen/scripting/go
export PATH=$PATH:/usr/local/src/go/bin
export shoveDir=/tmp/shove
_done $?

printf "Dynamic files: \n"
#Source everything in profile.d
INDENT=$(echo -e "  \xe2\x86\xb3")
if [ -d ~/profile.d ]; then
	for i in ~/profile.d/*.sh; do
		if [ -r $i ]; then
			printf "$INDENT `basename $i` ... "
			source $i
			_done $?
		fi
	done
fi

#BASH PROMPT SECTION
printf "\033[0mSetting aliases ..."
#ALIAS SECTION
alias bs='vi ~/.profile; . ~/.profile'
alias sb='. ~/.profile'
alias bp='vi ~/profile.d; . ~/.profile'
alias pshs='python -m SimpleHTTPServer 8585'
alias da='deactivate'
alias lg='ls -lah | grep'
_done $?
#FUNCTIONS FOR FUN AND AWESOMENESS

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
        cd $p
    fi
}

cm() {
    mkdir -p $1
    cd $1
}

venv() {
    b=`basename $PWD`
    if [[ -z $1 ]]
    then
        if [[ -d ~/.venv/$b ]]
        then
            source ~/.venv/$b/bin/activate
        else
            printf "Could not find virtual env for %s\n" "$b"
        fi
    else
        if [[ $1 == "2" || $1 == "3" ]]
        then
            virtualenv -p python$1 ~/.venv/$b
            source ~/.venv/$b/bin/activate
        else
            printf "Python version must be 2 or 3"
        fi
    fi
}

#pull all subdirectories of the current (or specified) dir
# usage: pullall [any path]
pullall() {
    PWDsave=$PWD
    if [ -n $1 ]
    then
        cd $1
    fi
    for dir in $("ls")
    do
        cd $dir
        git pull
        cd ..
    done
    cd $PWDsave
}

#Colorize stderr
# usage: colorize COMMAND [ARGS...]
colorize()(set -o pipefail; "$@" 2>&1>&3|sed $'s/.*/\e[1;31m&\e[m/'>&2)3>&1
