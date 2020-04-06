#!/bin/bash

cd "$( dirname "$0" )"

echo "Leave blank if you don't want to install module or populate parameters."
echo ""

while read -p "Module name? " MODULE; do
    if [ -z "${MODULE}" ]; then
        echo "Nothing to install!"
        break
    fi

    read -p "Pull request? " PR
    read -p "Branch? (default: dev) " BRANCH
    export MODULE=$MODULE
    export BRANCH=$BRANCH
    export PR=$PR
    vagrant up --provision
done
