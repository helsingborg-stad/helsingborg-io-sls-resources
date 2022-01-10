
#!/bin/bash
DIR=$(dirname $0)
OUTPUT=/tmp/parameters.txt

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
echo This script extracts AWS SSM Parameters from an AWS account and
echo creates a file with the commands for recreating them in another.
echo Before running, make sure that you are logged on to the account
echo of which parameters you want to extract.
echo
echo The currently active source account is \"${AWS_VAULT:Unknown}\"
echo
read -p "Type C to continue: " CHOICE

if [ "${CHOICE}" != "C" ]; then
    exit 1
fi

JSON=`aws ssm get-parameters-by-path \
        --path "/" \
        --recursive \
        --with-decryption \
        --query "Parameters[*].{Name:Name,Value:Value,Type:Type}" \
        --output json`

jq -r '.[] | @sh "aws ssm put-parameter --name \(.Name) --type \(.Type) --value \(.Value)\n\n"' <<< $JSON >${OUTPUT}

echo
echo The extraction has finished. Logon to the destination account using aws-vault exec \<account\>
echo and issue the commands from the file \"${OUTPUT}\" to complete the copy.
echo 

