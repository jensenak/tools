#!/bin/bash

path_file=~/.saved_paths

save_location() {
    if [[ "$1" =~ [A-Za-z0-9_]+ ]] 
    then
        existing="$(grep "^$1 " "$path_file" | cut -d\  -f3)"
        if [ -n "$existing" ]
        then
            echo "Current value of $1 = $existing"
            read -p "Overwrite? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                delete_location "$1"
            else
                echo "Doing nothing"
                return
            fi
        fi
        echo "$1 --> $(pwd)" >> "$path_file"
        echo "Saved"
    else
        echo "Place name must be alphanumeric and nonzero in length"
    fi
}

delete_location() {
    if [[ "$1" =~ [A-Za-z0-9_]+ ]]
    then
        sed -i.bak "/^$1/d" "$path_file"
        echo "Deleted"
    else
        echo "Place name must be alphanumeric and nonzero in length"
    fi
}

list_saved() {
    cat "$path_file"
}

jump_to() {
    if [ -n "$1" ]
    then
        to_path="$(grep "^$1 " "$path_file" | cut -d\  -f3)"
        if [ -z "$to_path" ]
        then
            echo "No location set"
        else
            cd "$to_path" || return
        fi
    else
        help
        echo "No place name provided"
    fi
}

help() {
cat <<EOF
Usage: to [command] [location name]

Commands:
    [none]   Given only a location name, to will cd to that location.
    save     Save the current working directory under the given name.
    del      Delete the stored location specified.
    ls       List stored locations.
    help     Print this message.

EOF
}

to() {
    if [ ! -O "$path_file" ]
    then
        touch "$path_file"
    fi

    case "$1" in
        ls) list_saved ;;
        save) save_location "$2" ;;
        del) delete_location "$2" ;;
        -h|help) help ;;
        *) jump_to "$1" ;;
    esac
}
