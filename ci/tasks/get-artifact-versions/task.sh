#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
cf_deployment_repo="${task_root}/cf-deployment"
cf_versions_output="${task_root}/cf-versions"

echo -e "\nGetting cf-deployment and capi versions..."
cf_deployment_version="$(<"${cf_deployment_repo}"/cf-deployment.yml yq '.manifest_version' -r)"
capi_version="$(<"${cf_deployment_repo}"/cf-deployment.yml grep -A 1 capi | grep version | cut -d ':' -f2 | sed 's/ //g')"

echo "cf_deployment_version: ${cf_deployment_version}" >> "${cf_versions_output}/cf_versions.yml"
echo "capi_version: ${capi_version}" >> "${cf_versions_output}/cf_versions.yml"

cat "${cf_versions_output}/cf_versions.yml"
