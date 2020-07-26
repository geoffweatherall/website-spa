#!/usr/bin/env bash
set -eo pipefail

# required parameter is apex domain name
if [ -z "$1" ]
  then
    echo "specify apex domain, e.g. mysite.com"
    exit 1
fi

domain_name=$1
stack_name=${domain_name//./-}-website-pipeline
shift

# find out physical name given to bucket holding website in stack

artifact_bucket_name=$(aws cloudformation describe-stack-resources \
  --stack-name $stack_name \
  --logical-resource-id ArtifactStoreBucket \
  --region us-east-1 \
  --query "StackResources[].PhysicalResourceId" \
  --output  text
)

aws s3 rm s3://$artifact_bucket_name --recursive

echo Deleting stack $stack_name

aws cloudformation delete-stack --stack-name $stack_name --region us-east-1


