#!/bin/bash

grab() {
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
