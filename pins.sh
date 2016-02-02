pin() {
	BOLD="$(tput bold)"
	RED="$BOLD$(tput setaf 1)"
	YELLOW="$BOLD$(tput setaf 3)"
	GREEN="$BOLD$(tput setaf 2)"
	BLUE="$BOLD$(tput setaf 4)"
	RESET="$(tput sgr0)"
	pinLocation=~/profile.d/.saved-pins
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
    elif [[ $1 == "del" ]]
    then
        if [ -z $2 ]
        then
            echo "No number given for removal"
        else
            IFS=':' read -ra PINS <<< "$PIN"
            export PIN=""
            rem=${PINS[$2]}
            echo Removing $rem
            for p in "${PINS[@]}"
            do
                if [[ "${p}x" != "${rem}x" ]]
                then
                    if [[ $PIN == "" ]]
                    then
                        export PIN=$p
                    else
                        export PIN=$PIN:$p
                    fi
                fi
            done
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
		echo $PIN > $pinLocation
		echo "$GREEN Saved$RESET"
	elif [[ $1 == "get" ]]
	then
		if [[ -r $pinLocation ]]
		then
			export PIN="$(cat $pinLocation)"
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
        echo ""
        echo "Valid options are: "
        echo " [number]     # jump to numbered pin"
        echo " list         # see numbered pins"
        echo " set          # set the current directory as only pin"
        echo " add          # add the current directory to the pin list"
        echo " del [number] # remove the pin at [number]"
        echo " write        # save pins to file"
        echo " get          # retrieve pins from file"
        echo " get [any]    # list pins"
        echo " [nothing]    # interactively choose a pin to jump to"
	fi
}

pin get quiet
