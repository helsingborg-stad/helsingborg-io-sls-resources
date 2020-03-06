#!/bin/bash -eu

# (C) Helsingborg Stad

FILES=./envs/*

# Confirm that we have the AWS cli
if ! [ -x "$(command -v "aws")" ]; then
  echo "Error: The aws-cli is not on the path. Perhaps it is not installed?"
  exit 1
fi

for f in $FILES
do
  echo "Processing $f file..."
  NAME=$(basename $f .json)
  # take action on each file. $f store current file name
  VALUE="`cat $f`"

  echo "Creating SSM paramter $NAME with value: $VALUE"

  aws ssm put-parameter   \
    --region eu-north-1   \
    --type SecureString   \
    --name "/$NAME/dev"   \
    --value "$VALUE" > /dev/null
done
