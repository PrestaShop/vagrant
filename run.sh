#!/bin/bash

cd "$( dirname "$0" )"

echo "Leave blank if you don't want to populate parameters."
echo ""

read -p "Pull request? " PR
read -p "Branch? (default: develop) " BRANCH
read -p "PHP version? (7.1 / 7.2 (default) / 7.3 / 7.4) " PHP_VERSION
read -p "Automatic installation? (0 / 1) " AUTOMATIC_INSTALL

export AUTOMATIC_INSTALL=$AUTOMATIC_INSTALL
export PHP_VERSION=$PHP_VERSION
export BRANCH=$BRANCH
export PR=$PR

vagrant up --provision
