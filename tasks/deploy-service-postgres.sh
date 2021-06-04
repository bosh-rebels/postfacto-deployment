#!/usr/bin/env bash

set -euf -o pipefail
source postfacto-deployment-code/tasks/cf-lib.sh

cf_auth "$OPSMAN_DOMAIN_OR_IP_ADDRESS" "$OPSMAN_USERNAME" "$OPSMAN_PASSWORD"
cf_create_service aws-rds-postgres standard postfacto-db
cf_wait_for_service_instance postfacto-db
