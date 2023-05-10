#!/bin/bash
DIR=$(dirname $0)

# Check node version
NODE=`node -v | cut -b2-3`

if [ 14 -gt `expr "${NODE}"` ]
then
    echo "Node v14 or higher is required to run this script"
    exit 1
fi

# Install serverless
yarn global add serverless

# Add services to deploy here (Order is important)
SERVICES=(
    "dynamos/cases"
    "dynamos/forms"
    "dynamos/users"
    "storage/attachments"
    "storage/certificates"
    "storage/pdf"
    "queues/viva"
    "gateway/root"
    "gateway/resources/auth"
    "gateway/resources/bookables"
    "gateway/resources/booking"
    "gateway/resources/cases"
    "gateway/resources/forms"
    "gateway/resources/search"
    "gateway/resources/status"
    "gateway/resources/timeslots"
    "gateway/resources/users"
    "gateway/resources/version"
)

# Run deployments
for SERVICE in "${SERVICES[@]}"
do
    cd "${DIR}/../services/${SERVICE}"
    sls deploy
    if [ $? != 0 ]
    then
        echo "FAILED SLS deploy"
        exit 1
    fi
done

