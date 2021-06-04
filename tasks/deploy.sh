#!/usr/bin/env bash

set -euf -o pipefail
source ./cf-lib.sh

cf_auth "$OPSMAN_DOMAIN_OR_IP_ADDRESS" "$OPSMAN_USERNAME" "$OPSMAN_PASSWORD"
cd package-tarball/package/tas/
./deploy.sh $APP_NAME
