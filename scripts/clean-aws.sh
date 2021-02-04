#!/usr/bin/env bash

# USE SCRIPT WITH CAUTION ⚠️ ⚠️ ⚠️

# DESCRIPTION
# Use this script to delete existing instances from AWS:
# buckets, gateways, dynamos, lambda functions, stacks (UPDATE_COMPLETE || CREATE_COMPLETE)

# REQUIREMENTS
# - This script depends on jq for parsing json, install using homebrew: brew install jq 👈
# - Setup default region & verify IAM user using AWS CLI: aws configure 👈👈

start() {
    echo "Do a dry run? (y/n) [n]: "
    read INPUT_DRY_RUN

    if [[ "$INPUT_DRY_RUN" != "y" ]]; then
        echo "This is your last chance. Are you really sure you want delete all buckets, dynamos, lambdas, gateways & stacks with their containing data from AWS?"
        echo "Type 'delete' and hit enter to execute 💣 : "
        read INPUT_CONFIRMATION
        
        if [[ "$INPUT_CONFIRMATION" != "delete" ]]; then
            echo 'Bye'
            exit 1
        else
            echo '😱';
        fi
    fi
}

deleteBuckets() {
    aws s3api list-buckets | jq -r '.Buckets[].Name' | while read BUCKET_NAME 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Bucket: $BUCKET_NAME"
        else
            echo $(aws s3 rb s3://$BUCKET_NAME --force) | jq -r 
        fi
    done
}

deleteDynamos() {
    aws dynamodb list-tables | jq -r '.TableNames[]' | while read TABLE_NAME 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Dynamo: $TABLE_NAME"
        else
            echo $(aws dynamodb delete-table --table-name=$TABLE_NAME) | jq -r 
        fi
    done
}

deleteLambdas() {
    aws lambda list-functions | jq -r '.Functions[].FunctionName' | while read FUNCTION_NAME 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Lambda: $FUNCTION_NAME"
        else
            echo $(aws lambda delete-function --function-name=$FUNCTION_NAME) | jq -r   
        fi
    done
}

deleteGateways() {
    aws apigateway get-rest-apis | jq -r '.items[].id' | while read GATEWAY_ID 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Gateway: $GATEWAY_ID"
        else
            echo $(aws apigateway delete-rest-api --rest-api-id=$GATEWAY_ID) | jq -r 
        fi
    done
}

deleteStacks() {
    aws cloudformation list-stacks --stack-status-filter=UPDATE_COMPLETE | jq -r '.StackSummaries[].StackName' | while read STACK_NAME 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Stack(UPDATE_COMPLETE): $STACK_NAME"
        else
            echo $(aws cloudformation delete-stack --stack-name=$STACK_NAME) | jq -r 
        fi
    done

    aws cloudformation list-stacks --stack-status-filter=CREATE_COMPLETE | jq -r '.StackSummaries[].StackName' | while read STACK_NAME 
    do
        if [[ "$INPUT_DRY_RUN" == "y" ]]; then
            echo "Stack(CREATE_COMPLETE): $STACK_NAME"
        else
            echo $(aws cloudformation delete-stack --stack-name=$STACK_NAME) | jq -r 
        fi
    done
}

init() {
    start
    deleteBuckets
    deleteDynamos
    deleteLambdas
    deleteGateways
    deleteStacks
}

init