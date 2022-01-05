#!/bin/bash

# (C) Helsingborg Stad

# Confirm that we have the AWS cli
if ! [ -x "$(command -v "aws")" ]; then
  echo "Error: The aws-cli is not on the path. Perhaps it is not installed?"
  exit 1
fi

FILES=./envs/"[^example.]*"
CMD=aws

usage() {
  echo "usage: ssmPutParameter.sh -s stage [-p profile -h]"
}

while [ "$1" != "" ]; do
  case $1 in
    -s | --stage )  shift
                    STAGE=$1
                    ;;
    -p | --profile ) shift
                    PROFILE=$1
                    ;;
    -h | --help )   usage
                    exit
                    ;;
    * )             usage
                    exit 1
  esac
  shift
done

if [ -z $STAGE ]; then
  echo "Error: Missing required option -s|--stage [stage]"
  exit 1
fi

if [ -n $PROFILE ]; then
  CMD="aws --profile=$PROFILE"
fi

for f in $FILES
do
  # Ignore if file starts with _
  [[ $f =~ ^.*_.* ]] && continue
  echo "Processing $f..."
  NAME=$(basename $f .json)
  # take action on each file. $f store current file name
  VALUE="`cat $f`"

  echo "Creating SSM paramter $NAME with value: $VALUE"

  $CMD ssm put-parameter    \
    --region eu-north-1     \
    --type SecureString     \
    --overwrite             \
    --name "/$NAME/$STAGE"  \
    --value "$VALUE" > /dev/null

done
