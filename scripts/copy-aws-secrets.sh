
#!/bin/bash
DIR=$(dirname $0)
OUTPUT=/tmp/secrets.txt

if [ -z ${AWS_VAULT} ]; then
    echo AWS Vault needs to be installed to run this script.
    exit 1
fi

which aws >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo AWS CLI needs to be installed to run this script.
    exit 1
fi

which jq >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo The JQ tool needs to be installed to run this script.
    exit 1
fi

clear
echo This script extracts AWS Secrets from an AWS account and
echo creates a file with the commands for recreating them in another.
echo Before running, make sure that you are logged on to the account
echo of which secrets you want to extract.
echo
echo The currently active source account is \"${AWS_VAULT:Unknown}\"
echo
read -p "Type C to continue: " CHOICE

if [ "${CHOICE}" != "C" ]; then
    exit 1
fi

LIST=`aws secretsmanager list-secrets --query "SecretList[*].Name" --output json`
 
>${OUTPUT}
for LINE in `jq -r ".[]" <<< ${LIST}`; do 
    VALUE=`aws secretsmanager get-secret-value \
        --secret-id "${LINE}" \
        --query "SecretString" \
        --output text`
    echo aws secretsmanager create-secret --name ${LINE} --secret-string \'${VALUE}\' >>${OUTPUT}
    echo >>${OUTPUT}
done

echo
echo The extraction has finished. Logon to the destination account using aws-vault exec \<account\>
echo and issue the commands from the file \"${OUTPUT}\" to complete the copy.
echo 

