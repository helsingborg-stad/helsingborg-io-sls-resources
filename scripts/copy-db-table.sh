
#!/bin/bash
DIR=$(dirname $0)
TABLE=dev-forms

while [[ $# -gt 1 ]]
do
    key="$1"
    case $key in
        -t | --table )
        TABLE="$2"
        shift
        ;;
        *)
        echo "Use --table <table-name> to specify which table to copy"
        exit 1
        ;;
    esac
    shift
done

OUTPUT=/tmp/${TABLE}.txt

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
echo This script extracts Items from the ${TABLE} dynamo db table of an
echo  AWS account and creates a file with the commands for recreating them in another.
echo Before running, make sure that you are logged on to the account
echo of which database you want to extract from.
echo
echo The currently active source account is \"${AWS_VAULT:Unknown}\"
echo
read -p "Type C to continue: " CHOICE

if [ "${CHOICE}" != "C" ]; then
    exit 1
fi

ITEMS=`aws dynamodb scan --table-name ${TABLE} --output json`
jq -r '.Items[] | "aws dynamodb put-item --table-name '${TABLE}' --item '\''\(.)'\''\n\n"' <<< $ITEMS > ${OUTPUT}

echo
echo The extraction has finished. Logon to the destination account using aws-vault exec \<account\>
echo and issue the commands from the file \"${OUTPUT}\" to complete the copy.
echo 

