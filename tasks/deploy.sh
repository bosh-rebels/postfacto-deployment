#!/usr/bin/env bash

set -euf -o pipefail

om_cli="om-linux -k -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS -u $OPSMAN_USERNAME -p $OPSMAN_PASSWORD"

cf_guid=$(${om_cli} curl --path /api/v0/deployed/products | jq -r '.[] | select(.type == "cf") | .guid')
cf_sys_domain=$(${om_cli} curl --path /api/v0/staged/products/${cf_guid}/properties \
                | jq -r '.properties[".cloud_controller.system_domain"].value')

cf_user=$($om_cli credentials -p cf -c .uaa.admin_credentials -f identity)
cf_password=$($om_cli credentials -p cf -c .uaa.admin_credentials -f password)

# Create org and space where nozzle is deployed
set +x
cf api api.${cf_sys_domain} --skip-ssl-validation
cf auth ${cf_user} ${cf_password}
set -x

cf target -o demo -s demo
cd package-tarball/package/tas/
./deploy.sh $APP_NAME
