#!/bin/bash

grab() {
# Note that shoveDir should be set in the environment
# shellcheck disable=SC2154
if [ -z "$shoveDir" ]; then
	echo "No shove dir set"
	return
fi

for f in $shoveDir/*
do
	echo "Moving $f to $(pwd)"
	mv "$f" .
done

}
