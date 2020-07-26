#!/usr/bin/env bash
set -eo pipefail

if [ -z "$1" ]
  then
    echo "specify target bucket for resources to be copied into"
    exit 1
fi
bucket_name=$1
shift

echo Copying web-app build into bucket $bucket_name

echo '----------------------------- hashed resources -----------------------------'

# copy immutable (i.e. hashed) dependant resources first - index.html will depend on these being present
# these can be safely cached for a long time as any changes in content will cause a change in hash.
# cache length is one year
aws s3 sync web-app/build/ s3://$bucket_name --metadata-directive REPLACE  --exclude index.html --cache-control public,max-age=31536000

echo '----------------------------- index.html -----------------------------'

# copy index.html with no caching (so release is instant without needing CloudFront invalidation)
aws s3 sync web-app/build/ s3://$bucket_name --metadata-directive REPLACE  --exclude "*" --include index.html --cache-control no-store
