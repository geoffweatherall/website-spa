#!/usr/bin/env bash
set -eo pipefail

# required parameter apex domain name
if [ -z "$1" ]
  then
    echo "specify apex domain, e.g. mysite.com"
    exit 1
fi

domain_name=$1
stack_name=${domain_name//./-}-website-pipeline
shift

# required parameter github repository
if [ -z "$1" ]
  then
    echo "specify github repository, e.g. example-spa-hosting"
    exit 1
fi

github_repository=$1
shift


aws cloudformation deploy \
  --template-file pipeline/website-pipeline.cfn.yaml \
  --stack-name ${stack_name} \
  --region us-east-1 \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
     ApexDomain=${domain_name} \
     GitHubRepoName=${github_repository} \
   "$@"