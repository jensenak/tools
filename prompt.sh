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

#Add the stuff together, see how long it will be (chars)
promptsize=$(echo -n "${filler}${rooty}$PWD$day" | wc -c | tr -d " ")
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
bright="\033[1;32;100m"
light="\033[1;34;100m"
mid="\033[0;33;100m"
dark="\033[0;30;100m"
nobg="\033[1;35m"

#The actual prompt that will be used
if [[ -n $VIRTUAL_ENV ]] || [[ -n $(__git_ps1) ]]
then
	p1=' '
	if [[ -n $VIRTUAL_ENV ]]
	then 
		p1=$(basename $VIRTUAL_ENV)
	fi
	if [[ -n $(__git_ps1) ]]
	then
		p2=$(__git_ps1)
	fi
	PS1="\n$nobg$p1$p2$reset\n$dark$filler $mid$rooty$bright$PWD$dark$fill $light$day$reset\n>> "
else
	PS1="\n$dark$filler $mid$rooty$bright$PWD$dark$fill $light$day$reset\n>> "
fi
}
