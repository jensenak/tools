#Source this file and use the function to save multiple "cd" locations

pin() {
	BOLD="$(tput bold)"
	RED="$BOLD$(tput setaf 1)"
	YELLOW="$BOLD$(tput setaf 3)"
	GREEN="$BOLD$(tput setaf 2)"
	BLUE="$BOLD$(tput setaf 4)"
	RESET="$(tput sgr0)"
	if [[ -z $1 ]]
	then
		if [[ -z $PIN ]] 
		then
			echo "$RED Couldn't change your location, no pin set$RESET"
		else
			IFS=':' read -ra PINS <<< "$PIN"
			if [[ ${#PINS[@]} -gt 0 ]]
			then
				echo "$BOLD Choose a pin$RESET"
				i=0
				for l in "${PINS[@]}"
				do
					echo $BLUE $i $RESET $l
					i=$((i+1))
				done
				read opt
				echo " Jumping to $GREEN${PINS[$opt]}$RESET"
				cd ${PINS[$opt]}
			else
				echo " Jumping to $GREEN$PIN$RESET"
				cd $PIN
			fi
		fi
	elif [[ $1 == "set" ]]
	then
		export PIN=$(pwd)
		echo " Set pin to $YELLOW$PIN$RESET"
	elif [[ $1 == "add" ]]
	then
		if [[ -z $PIN ]]
		then
			echo " Set pin to $YELLOW$(pwd)$RESET"
			export PIN=$(pwd)
		else
			echo " Set pin to $PIN:$YELLOW$(pwd)$RESET"
			export PIN=$PIN:$(pwd)
		fi
	elif [[ $1 == "list" ]] 
	then
		echo "$BOLD Current pins$RESET"
		IFS=':' read -ra PINS <<< "$PIN"
		for l in "${PINS[@]}"
		do
			echo $l
		done
	elif [[ $1 == "write" ]]
	then
		echo $PINS > ~/.saved_pins
		echo "$GREEN Saved$RESET"
	elif [[ $1 == "get" ]]
	then
		if [[ -r ~/profile.d/.saved_pins ]]
		then
			export PINS="$(cat ~/profile.d/.saved_pins)"
		fi
		if [[ -z $2 ]]
		then 
			pin list
		fi
	elif [[ $1 =~ ^-?[0-9]+$ ]]
	then
		IFS=':' read -ra PINS <<< "$PIN"
		if [[ ${#PINS[@]} -gt $1 ]]
		then
			echo " Jumping to $GREEN${PINS[$1]}$RESET"
			cd ${PINS[$1]}
		else
			echo " Pin $1 not found"
		fi	
	else
		echo "$RED Option $1 not found"
	fi
}

pin get quiet