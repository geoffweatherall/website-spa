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

if [ ! -d "web-app/build/" ]
  then
    echo "web-app must be built before running this script, run 'npm install' and 'npm run build' in web-app directory"
    exit 2
fi




# find out physical name given to bucket holding website in stack

web_resources_bucket_name=$(aws cloudformation describe-stack-resources \
  --stack-name $website_hosting_stack_name \
  --logical-resource-id WebResourcesBucket \
  --region us-east-1 \
  --query "StackResources[].PhysicalResourceId" \
  --output  text
)

# copy immutable (i.e. hashed) dependant resources first - index.html will depend on these being present
aws s3 sync web-app/build/ s3://${web_resources_bucket_name} --metadata-directive REPLACE  --exclude index.html --cache-control public,max-age=31536000

# copy index.html with no caching (so release is instant without needing invalidation)
aws s3 sync web-app/build/ s3://${web_resources_bucket_name} --metadata-directive REPLACE  --exclude "*" --include index.html --cache-control no-store

