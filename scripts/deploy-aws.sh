#!/usr/bin/env bash

# DESCRIPTION
# Run this script to execute 'sls deploy' in dirs with serverless.yml file

start() {
    if [[ ! -d "./services" ]]; then
        echo "Could not find ./services directory, try running the script again from the project root."
        exit 1
    fi

    echo "Proceed to bulk deploy cloud resources n' sh*t to AWS? 🚀 [y/n]: "
    read INPUT_CONFIRMATION

    if [[ "$INPUT_CONFIRMATION" != "y" ]]; then
        echo 'Bye'
        exit 1
    fi
}

deployBuckets() {
    for DIR_PATH in $(find . -maxdepth 3 -name "serverless.yml" -not -path "*/node_modules/*" -type f -exec dirname {} \;); do
        echo $(cd $DIR_PATH;sls deploy)
    done
}

deployDynamos() {
    for DIR_PATH in $(find services/dynamos -name "serverless.yml" -not -path "*/node_modules/*" -type f -exec dirname {} \;); do
        echo $(cd $DIR_PATH;sls deploy)
    done
}

deployGateways() {
    for DIR_PATH in $(find services/gateway -name "serverless.yml" -not -path "*/node_modules/*" -type f -exec dirname {} \;); do
        echo $(cd $DIR_PATH;sls deploy)
    done
}

init() {
    start
    deployBuckets
    deployDynamos
    deployGateways
}

init
