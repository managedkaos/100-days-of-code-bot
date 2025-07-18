#!/bin/bash

# If no stack name is provided,
if [ -z "$1" ]; then
  echo None
  exit 1
fi

# $1 == development then stack name is one-hundred-days-of-code-development
# $1 == production then stack name is one-hundred-days-of-code-production
if [ "$1" == "development" ]; then
  STACK_NAME="one-hundred-days-of-code-development"
elif [ "$1" == "production" ]; then
  STACK_NAME="one-hundred-days-of-code-production"
else
  echo None
  exit 1
fi

endpoint=$(aws cloudformation describe-stacks --region us-east-1 --stack-name ${STACK_NAME} --query "Stacks[0].Outputs[].[OutputValue] | [2]" --output=text)


curl -sLk --max-time 30 --write-out "\n\n%{time_total} %{num_redirects} %{http_code} %{url_effective}\n" ${endpoint}
