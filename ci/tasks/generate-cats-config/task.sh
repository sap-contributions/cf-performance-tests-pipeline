#!/bin/bash

set -euo pipefail

pushd "bbl-state/state" >/dev/null
  eval "$(bbl print-env)"
popd >/dev/null

echo "::: Generating config :::"
bosh_director_name="$(jq --raw-output '.bosh.directorName' bbl-state/state/bbl-state.json)"
cf_admin_password="$(credhub get --name "/${bosh_director_name}/cf/cf_admin_password" --output-json | jq --raw-output '.value')"

config_json="$(jq --null-input '{
  "api": "'"api.${SYSTEM_DOMAIN}"'",
  "apps_domain": "'"${SYSTEM_DOMAIN}"'",
  "admin_user": "admin",
  "admin_password": "'"${cf_admin_password}"'",
  "use_http": false,
  "skip_ssl_validation": true,
  "include_apps": false,
  "include_detect": false,
  "include_security_groups": true,
  "include_routing": true,
  "include_tcp_routing": true
  }')"

echo "$config_json" > integration-config/integration_config.json
echo "::: Done :::"
