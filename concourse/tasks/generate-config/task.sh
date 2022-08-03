#!/bin/bash

set -eu
set -x

echo "::: Generating config :::"
mkdir -p integration-config

BOSH_DIRECTOR_NAME="$(bbl-state/state/bbl-state.json jq -r .bosh.directorName)"
CF_ADMIN_PASSWORD="$(credhub get -n "/$BOSH_DIRECTOR_NAME/cf/cf_admin_password" -j | jq -r .value)"

config_json=$(jq -n '{
  "api": "'"api.$SYSTEM_DOMAIN"'",
  "apps_domain": "'"$SYSTEM_DOMAIN"'",
  "admin_password": "'"$CF_ADMIN_PASSWORD"'"
  }')

echo $config_json > integration-config/integration_config.json
