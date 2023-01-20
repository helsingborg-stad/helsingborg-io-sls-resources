#!/bin/bash
DIR=$(dirname $0)

# Stacks to remove
SERVICES=(
    "gateway/resources/version"
    "gateway/resources/users"
    "gateway/resources/timeslots"
    "gateway/resources/search"
    "gateway/resources/forms"
    "gateway/resources/cases"
    "gateway/resources/booking"
    "gateway/resources/bookables"
    "gateway/resources/auth"
    "queues/viva"
    "gateway/root"
    "storage/pdf"
    "storage/certificates"
    "storage/attachments"
    "dynamos/users"
    "dynamos/forms"
    "dynamos/cases"
)

# Perform removal
for SERVICE in "${SERVICES[@]}"
do
    echo "Removing stack: ${SERVICE}"
    cd ${DIR}/../services/${SERVICE}
    # Remove stack
    sls remove
done
