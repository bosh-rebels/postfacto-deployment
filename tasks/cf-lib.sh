cf_auth() {
  local opsman_domain_or_ip_address=${1:-127.0.0.1}
  local opsman_username=${2:-user}
  local opsman_password=${3:-pass}
  om_cli="om-linux -k -t https://$opsman_domain_or_ip_address -u $opsman_username -p $opsman_password"

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
}

cf_service_exists() {
  local cf_service_name=${1}
  cf service $cf_service_name --guid 2>/dev/null
}

# returns the service instance guid, otherwise null if not found
function cf_get_service_instance_guid() {
  local service_instance=${1:?service_instance null or not set}
  # swallow "FAILED" stdout if service not found
  local service_instance_guid=
  if service_instance_guid=$(CF_TRACE=false cf service "$service_instance" --guid 2>/dev/null); then
    echo "$service_instance_guid"
  fi
}

# returns true if service exists, otherwise false
function cf_service_exists() {
  local service_instance=${1:?service_instance null or not set}
  local service_instance_guid=$(cf_get_service_instance_guid "$service_instance")
  [ -n "$service_instance_guid" ]
}

function cf_create_service() {
  local service=${1:?service null or not set}
  local plan=${2:?plan null or not set}
  local service_instance=${3:?service_instance null or not set}
  local broker=${4:-}
  local configuration=${5:-}
  local tags=${6:-}

  local args=("$service" "$plan" "$service_instance")
  [ -n "$broker" ]        && args+=(-b "$broker")
  [ -n "$configuration" ] && args+=(-c "$configuration")
  [ -n "$tags" ]          && args+=(-t "$tags")

  cf create-service "${args[@]}"
}

function cf_wait_for_service_instance() {
  local service_instance=${1:?service_instance null or not set}
  local timeout=${2:-600}

  local guid=$(cf_get_service_instance_guid "$service_instance")
  if [ -z "$guid" ]; then
    echo "Service instance does not exist: $service_instance"
    exit 1
  fi

  local start=$(date +%s)

  echo "Waiting for service: $service_instance"
  while true; do
    # Get the service instance info in JSON from CC and parse out the async 'state'
    local state=$(cf curl "/v2/service_instances/$guid" | jq -r .entity.last_operation.state)

    if [ "$state" = "succeeded" ]; then
      echo "Service is ready: $service_instance"
      return
    elif [ "$state" = "failed" ]; then
      local description="$(cf curl "/v2/service_instances/$guid" | jq -r .entity.last_operation.description)")
      echo "Failed to provision service: $service_instance error: $description"
      exit 1
    fi

    local now=$(date +%s)
    local time=$(($now - $start))
    if [[ "$time" -ge "$timeout" ]]; then
      echo "Timed out waiting for service instance to provision: $service_instance"
      exit 1
    fi
    sleep 5
  done
}