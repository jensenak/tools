#!/bin/bash

shove() {
if [ -z "$shoveDir" ]; then
	export shoveDir=/tmp/shove
fi

if [ ! -d $shoveDir ]; then
	mkdir -p "$shoveDir"
fi

if [[ $1 == "-c" ]]; then
	shift
	for f in "$@"
	do
		echo "Copying $f to $shoveDir"
		cp $f "$shoveDir"
	done
else
	for f in "$@"
	do
		echo "Moving $f to $shoveDir"
		mv $f "$shoveDir"
	done
fi
}
