#!/bin/bash
# Source this file and set PROMPT_COMMAND='getPrompt'
getPrompt() {
filler=$(echo -e "\xe2\x96\x81")
TERMWIDTH=${COLUMNS}

#If we're root, say so
rooty=''
if [[ $EUID == 0 ]]; then
    rooty='-=< SUPER >=- '
fi

#What is today?
day=$(date +%m-%d\ %R:%S)

#If working dir is too long, trim
mwd=$PWD
if [[ ${#mwd} -gt $((TERMWIDTH/2)) ]]
then
    # shellcheck disable=2034
    halfwide=$((TERMWIDTH/2-3))
    mwd="...${PWD: -halfwide}"
fi

#Add the stuff together, see how long it will be (chars)
promptsize=$(echo -n "${filler}${rooty}$mwd$day" | wc -c | tr -d " ")
fillsize=$((TERMWIDTH-promptsize))
fill=""

#Generate a string of equals signs to fill up empty space
while [ "$fillsize" -gt "0" ]
do
    fill="${fill}${filler}"
    fillsize=$((fillsize-1))
done

#Set colors and shades and resets and stuff
reset="\033[0m"
cMain="\033[1;32m"
cDay="\033[1;33m"
cRoot="\033[1;33m"
cFill="\033[0;30m"
cGit="\033[1;35m"
cAws="\033[0;36m"
cVenv="\033[1;33m"

#The actual prompt that will be used
venv=' '
if [[ -n $VIRTUAL_ENV ]]
then 
    venv=$(basename "$VIRTUAL_ENV")
fi
gitstat=$(__git_ps1)
PS1="\n $cVenv$venv$cGit$gitstat $cAws$AWS_PROFILE $AWS_DEFAULT_REGION$reset\n$cFill$filler $cRoot$rooty$cMain$mwd$cFill$fill $cDay$day$reset\n>> "
}
