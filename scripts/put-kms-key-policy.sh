
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
echo This script puts a new key policy on the customer provided AWS KMS key
echo named external/master. The policy allows AWS EventBridge to put messages
echo on AWS SQS when encryption is enabled with the customer provided KMS key.
echo
echo The currently active source account is \"${AWS_VAULT:Unknown}\"
echo
read -p "Type Y to continue: " CHOICE

if [ "${CHOICE}" != "Y" ]; then
    echo "Exiting script..."
    exit 1
fi


ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
KEY_POLICY_NAME="default"
KEY_ALIAS="alias/external/master"
KEY_ID=$(aws kms describe-key \
    --key-id "${KEY_ALIAS}" \
    --query "KeyMetadata.KeyId" \
    --output text)

POLICY='{
    "Version": "2012-10-17", 
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::'${ACCOUNT_ID}':root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow EventBridge to use the key",
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey"
            ],
            "Resource": "*"
        }
    ]
}'

if [ -z ${KEY_ID} ]; then
    echo "No key id found for key with alias ${KEY_ALIAS}"
    exit 1
fi

aws kms put-key-policy \
    --policy-name "${KEY_POLICY_NAME}" \
    --key-id "${KEY_ID}" \
    --policy "${POLICY}"
