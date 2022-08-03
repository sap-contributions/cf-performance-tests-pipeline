#!/bin/bash

set -eu
set -x

echo "::: Generating config :::"

BOSH_DIRECTOR_NAME="$(jq --raw-output '.bosh.directorName' bbl-state/state/bbl-state.json)"
CF_ADMIN_PASSWORD="$(credhub get --name "/$BOSH_DIRECTOR_NAME/cf/cf_admin_password" --output-json | jq --raw-output '.value')"

config_json=$(jq --null-input '{
  "api": "'"api.$SYSTEM_DOMAIN"'",
  "apps_domain": "'"$SYSTEM_DOMAIN"'",
  "admin_password": "'"$CF_ADMIN_PASSWORD"'",
  "use_http": false,
  "skip_ssl_validation": true,
  "admin_user": "admin",
  "include_apps": false,
  "include_detect": false,
  "include_security_groups": true,
  "include_routing": true,
  "include_tcp_routing": true
  }')

echo "$config_json" > integration-config/integration_config.json

echo "::: Done :::"
