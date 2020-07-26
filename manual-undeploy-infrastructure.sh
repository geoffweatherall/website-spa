#!/usr/bin/env bash
set -eo pipefail

# required parameter is apex domain name
if [ -z "$1" ]
  then
    echo "specify apex domain, e.g. mysite.com"
    exit 1
fi

domain_name=$1
website_hosting_stack_name=${domain_name//./-}-website-hosting
shift

# find out physical name given to bucket holding website in stack

web_resources_bucket_name=$(aws cloudformation describe-stack-resources \
  --stack-name $website_hosting_stack_name \
  --logical-resource-id WebResourcesBucket \
  --region us-east-1 \
  --query "StackResources[].PhysicalResourceId" \
  --output  text
)

aws s3 rm s3://$web_resources_bucket_name --recursive

echo Deleting stack $website_hosting_stack_name

aws cloudformation delete-stack --stack-name $website_hosting_stack_name --region us-east-1


