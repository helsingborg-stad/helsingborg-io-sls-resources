#!/bin/zsh
DIR=${0:a:h}

# Check node version
NODE=`node -v | cut -b2-3`

if [ 14 -gt `expr "${NODE}"` ]
then
    echo "Node v14 or higher is required to run this script"
    exit 1
fi

# Check yarn availability
which yarn

if [ 0 -ne $? ]
then
    echo "Yarn needs to be installed to run this script"
    exit 1
fi

# Remove node modules
if [ -d ${DIR}/../node_modules ]
then
    echo "Removing node_modules directory"
    rm -fr ${DIR}/../node_modules
fi

# Install packages
yarn install

if [ $? != 0 ]
then
    echo "FAILED Yarn install"
    exit 1
fi

# Run Audit (Ignores dev-dependencies)
yarn audit --groups dependencies

if [ $? != 0 ]
then
    echo "FAILED Yarn Audit"
    exit 1
fi
