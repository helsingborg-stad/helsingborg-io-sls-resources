
#!/bin/zsh
DIR=${0:a:h}

TABLE=dev-forms

while [ "$1" != "" ]; do
    case $1 in
        -t | --table )
            shift
            TABLE=$1
        ;;
        *)      
            exit 1
    esac
    shift
done

OUTPUT=/tmp/${TABLE}.txt

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

