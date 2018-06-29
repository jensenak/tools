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
let fillsize=${TERMWIDTH}-${promptsize}
fill=""

#Generate a string of equals signs to fill up empty space
while [ "$fillsize" -gt "0" ]
do
    fill="${fill}${filler}"
    let fillsize=${fillsize}-1
done

#Set colors and shades and resets and stuff
reset="\033[0m"
bright="\033[0;32;100m"
light="\033[0;33;100m"
mid="\033[0;33;100m"
dark="\033[0;30;100m"
n1="\033[1;35m"
n2="\033[1;36m"
n3="\033[1;33m"

#The actual prompt that will be used
p1=' '
if [[ -n $VIRTUAL_ENV ]]
then 
    p1=$(basename "$VIRTUAL_ENV")
fi
p2=$(__git_ps1)
PS1="\n $n3$p1$n1$p2 $n2$AWS_PROFILE $AWS_DEFAULT_REGION$reset\n$dark$filler $mid$rooty$bright$mwd$dark$fill $light$day$reset\n>> "
}
