# shellcheck disable=SC1090,1091
# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022
export TRAIL="$TRAIL:profile"

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
set -o vi
source /usr/local/etc/bash_completion
export PATH="$PATH:/usr/local/sbin:/Users/adamjensen/Library/Python/3.7/bin"
export GIT_PS1_SHOWDIRTYSTATE=true
export HISTCONTROL=ingoredups:erasedups
export HISTSIZE=100000
export HISTFILESIZE=100000
shopt -s histappend
[ "$TERM" != "unknown" ] && printf "Loading env vars ... "
#ENVIRONMENT VARS I WANT SET
export PROMPT_COMMAND='history -a; getPrompt'
#'history -a; history -c; history -r; getPrompt'

LSCOLORS='exgxHxDxCxaDedecgcEhEa'
export LSCOLORS
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:/usr/share/man:/usr/local/share/man:/usr/X11/share/man"
export shoveDir=/tmp/shove
export GREP_COLORS='1;33;44'
export tgm="--terragrunt-source /Users/adamjensen/repos/infra-modules/"
#export AWS_PROFILE=core-nonprod
export AWS_DEFAULT_REGION=us-west-2
export NODE_OPTIONS="--max-old-space-size=4096"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
[ "$TERM" != "unknown" ] && _done $?

 
[ "$TERM" != "unknown" ] && printf "Dynamic files: \n"
#Source everything in profile.d
INDENT=$(echo -e "  \xe2\x86\xb3")
if [ -d ~/profile.d ]; then
    for i in ~/profile.d/*.sh; do
        if [ -r "$i" ]; then
            # shellcheck disable=SC2086
            [ "$TERM" != "unknown" ] && printf "%s %s ... " "$INDENT" "$(basename $i)"
            if ! shellcheck -s bash "$i" > /dev/null
            then
                [ "$TERM" != "unknown" ] && _done 1
            else
                source "$i"
                [ "$TERM" != "unknown" ] && _done $?
            fi
        fi
    done
fi

tab_random

#BASH PROMPT SECTION
[ "$TERM" != "unknown" ] && printf "\033[0mSetting aliases ..."
#ALIAS SECTION
alias glog='git log --pretty=oneline -n10'
alias uuid='python3 -c "from uuid import uuid4; print(uuid4());"'
alias grep='ggrep --color=always'
alias bs='edit_profile'
alias retry='edit_profile true'
alias cleanup='clean_profiles'
alias undo='undo_profile_change'
alias lsp='list_profiles'
alias sb='. ~/.profile'
alias bp='vi ~/profile.d; . ~/.profile'
alias pshs='python -m SimpleHTTPServer 8585'
alias da='deactivate'
alias ll='ls -lah'
alias lg='ls -lah | grep'
alias lsi='~/tools/lsi.sh'
alias icat='~/tools/imgcat.sh'
alias gokid='cd ~/repos/notes/scripts/kount-intg-deployer'
alias next='~/repos/notes/scripts/next'
alias gpa='gitpullall'
alias gpd='gitpulldirs'
alias ravenproxy='ssh -CnfND 8080 raven'
alias fh='fixhost'
alias y2j="python3 -c 'import sys, yaml, json; yaml.add_multi_constructor(\"!\", lambda loader, suffix, node: \"{} {}\".format(suffix, node.value)); json.dump(yaml.load(sys.stdin), sys.stdout, indent=4, sort_keys=True, default=str)'"
alias dcp="docker-compose"
alias dm="docker-machine"
alias dmstart='eval $(docker-machine env akj1)'
alias netstat='lsof -PMni4 | grep LISTEN'
alias realnestat='netstat'
alias ap='aws_profile'
alias ar='aws_region'
alias pip3='python3 -m pip'
[ "$TERM" != "unknown" ] && _done $?
#FUNCTIONS FOR FUN AND AWESOMENESS

ecsami() {
    printf "%s" "$(aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux/recommended | python -c 'import sys, json; json.dump(json.loads(json.load(sys.stdin)["Parameters"][0]["Value"])["image_id"], sys.stdout)')"
}

prox() {
    ssh -i ~/.ssh/keet-dev.pem -L "$2:$3:$4" "ec2-user@$3" -o "proxycommand ssh -W %h:%p -i ~/.ssh/jensenak_id_rsa adam@bastion-$1"
}

ecsip () {
  env="$1" # First arg is environment, e.g. dev, qa02, prod02
  svc="$2" # Second arg is service name, e.g. keet-api-web
  task_arn="$(aws ecs list-tasks --cluster "$env"-ecs-cluster --service "$svc" | jq -r '.taskArns[0]')";
  cont_id="$(aws ecs describe-tasks --cluster "$env"-ecs-cluster --task "$task_arn" | jq -r '.tasks[0].containerInstanceArn')";
  ec2_id="$(aws ecs describe-container-instances --cluster "$env"-ecs-cluster --container-instances "$cont_id" | jq -r '.containerInstances[0].ec2InstanceId')";
  aws ec2 describe-instances --instance-id "$ec2_id" | jq -r '.Reservations[0].Instances[0].NetworkInterfaces[0].PrivateIpAddress'
}

hop() {
  env="$1" # First arg is environment, e.g. dev, qa02, prod02
  ip="$2"
  ssh -i ~/.ssh/jensenak_id_rsa "adam@$ip" -o "proxycommand ssh -W %h:%p -i ~/.ssh/jensenak_id_rsa adam@bastion-$env"
}

jump() {
  env="$1" # First arg is environment, e.g. dev, qa02, prod02
  ip="$2"
  ssh -i ~/.ssh/keet-dev.pem "ec2-user@$ip" -o "proxycommand ssh -W %h:%p -i ~/.ssh/jensenak_id_rsa adam@bastion-$env"
}

jumps() {
  env="$1" # First arg is environment, e.g. dev, qa02, prod02
  svc="$2" # Second arg is service name, e.g. keet-api-web
  ip="$(ecsip "$env" "$svc")"
  bastion_suffix=${env//[0-9]/}
  ssh -i ~/.ssh/keet-dev.pem "ec2-user@$ip" -o "proxycommand ssh -W %h:%p -i ~/.ssh/jensenak_id_rsa adam@bastion-$bastion_suffix"
}

aws_profile() {
    if [ -z "$1" ]
    then
        printf "Unsetting profile\nAvailable profiles are:\n"
        grep -oP '(?<=profile )(\w+)' ~/.aws/config
    fi
    export AWS_PROFILE="$1"
}

aws_region() {
    if [ -z "$1" ]
    then
        printf "Using default region for your profile\n"
        unset AWS_DEFAULT_REGION
    else
        export AWS_DEFAULT_REGION="$1"
    fi
}

clean_profiles() {
    find ~/tmp/ -name 'profile*' -type f -delete
}

undo_profile_change() {
    cp ~/.profile ~/.profile.redo
    cp ~/.profile.bak ~/.profile
}

# Edits this file, but performs shell check before sourcing it again
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
        ls -1 ~/tmp/profile*
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
    select profileName in ~/tmp/profile*
    do
        printf "%s" "$profileName"
        break
    done
}

_edit_profile() {
    RED=$(tput setaf 1)
    YELLOW=$(tput setaf 3)
    GREEN=$(tput setaf 2)
    RESET=$(tput sgr0)
    profileName=$1
    if [ ! -e "$profileName" ]
    then
        printf "%s Could not find tmp file '%s' for editing %s" "$RED" "$profileName" "$RESET"
    else
        vi "$profileName"
        existing="$(md5sum ~/.profile | awk '{ print $1 }')"
        changed="$(md5sum "$profileName" | awk '{ print $1 }')"
        if [ "$existing" = "$changed" ]
        then
            printf "%s ## Nothing changed ## %s\n" "$YELLOW" "$RESET"
            return
        fi
        if ! shellcheck -s bash "$profileName"
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
        if [[ -d $venv_path/$b ]]
        then
            source "$venv_path/$b/usr/local/bin/activate"
        else
            printf "Could not find virtual env for %s\n" "$b"
        fi
    else
        if [[ $1 == "2" || $1 == "3" ]]
        then
            virtualenv -p "python$1" --activators bash "$venv_path/$b"
            source "${venv_path}$b/usr/local/bin/activate"
        else
            if [[ -d "$venv_path/$1" ]]
            then
                source "$venv_path/$1/usr/local/bin/activate"
            fi
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

fixhost() {
    if [ -z "$1" ]
    then
        printf "Please specify a line number to delete\n"
        return
    fi
    gsed -i "${1}d" ~/.ssh/known_hosts
}

gitpulldirs() {
    find . -type d -depth 1 -exec git --git-dir={}/.git --work-tree="$PWD"/{} pull \;
}

gitpullall() {
    START=$(git symbolic-ref --short -q HEAD);
    for branch in $(git branch | sed 's/^.//'); do
        git checkout "$branch"
        git pull "${1:-origin}" "$branch" || break
    done
    git checkout "$START"
}

#Colorize stderr
# usage: colorize COMMAND [ARGS...]
colorize()(set -o pipefail; "$@" 2>&1>&3|sed $'s/.*/\e[1;31m&\e[m/'>&2)3>&1

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
