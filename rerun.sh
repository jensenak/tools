#!/bin/bash
# rerun.sh
lockfile_name="$(mktemp /tmp/lockfile.XXXXXX)" # change appropriately
trap 'rm -f "$lockfile_name"' EXIT

exec 3>"$lockfile_name" # open lockfile on FD 3
kill_children() {
    # close our own handle on the lockfile
    exec 3>&-

    # kill everything that still has it open (our children and their children)
    fuser -k "$lockfile_name" >/dev/null

    # ...then open it again.
    exec 3>"$lockfile_name"
}

rerun() {
    trap 'kill_children; exit 0' SIGINT SIGTERM
    printf -v format '%b' "\033[1;33m%w%f\033[0m written"

    "$@" &

    #When a file changes in the directory, rerun the process
    while inotifywait -qre close_write --format "$format" .; do
        kill_children
        "$@" &
    done
}

rerun "$@"
