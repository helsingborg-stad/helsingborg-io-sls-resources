#!/bin/bash
DIR=$(dirname $0)

if [ -z ${AWS_VAULT} ]; then
     echo AWS Vault needs to be installed to run this script.
     exit 1
 fi

 which aws >/dev/null 2>&1

 if [ $? -ne 0 ]; then
     echo AWS CLI needs to be installed to run this script.
     exit 1
 fi

 clear
 echo This script removes AWS S3 buckets from an AWS account.
 echo Before running, make sure that you are logged on to the account
 echo of which buckets you want to remove
 echo
 echo The currently active source account is \"${AWS_VAULT:Unknown}\"
echo

BUCKETS=(`aws s3 ls | cut -f3 -d' '`)

for BUCKET in ${BUCKETS[@]}
do
    while read -r -n1 -p "Remove bucket ${BUCKET} [y/n]? " ANSWER;do
        echo
        if [ "${ANSWER}" == "y" ]; then
            echo "Removing bucket: ${BUCKET}"
            aws s3 rm s3://${BUCKET} --recursive
            aws s3 rb s3://${BUCKET}
        fi
        break;
    done
done