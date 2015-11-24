#!/bin/sh

set -ue

if [ $# -ne 3 ]; then
    echo "Usage: repo branch cmd_relative_to_repo_root" 1>&2
    exit 1
fi

repo="$1"
branch="$2"
cmd="$3"

cleanup()
{
    kill $child
}

kill_child()
{
    if [ $child -ne -1 ]; then
        kill $child
        wait
    fi
}

trap "cleanup" SIGINT SIGTERM

child=-1
while :; do
    cd /
    rm -rf /tmp/repo

    git clone --recursive --branch "$branch" "$repo" /tmp/repo
    cd /tmp/repo

    last_head=""
    while :; do
        git pull --ff-only -q || break

        this_head=`git rev-parse HEAD`
        [ $this_head = `git rev-parse origin/$branch` ] || break

        if [ ! "$this_head" = "$last_head" ]; then
            last_head=`git rev-parse HEAD`

            kill_child
            $cmd &
            child=$!
        fi

        sleep 60
    done

    kill_child
done
