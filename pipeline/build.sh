#!/usr/bin/env bash
set -eo pipefail

pushd web-app
npm install
npm run build
popd