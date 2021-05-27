#!/usr/bin/env bash

set -euf -o pipefail

cd package/tas
cf target -o system -s team-tools
./deploy.sh $APP_NAME
