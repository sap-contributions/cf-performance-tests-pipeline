#!/bin/bash

set -eu

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
cf_perf_tests_repo="${task_root}/cf-performance-tests"
cf_deployment_repo="${task_root}/cf-deployment"
bbl_state="${task_root}/bbl-state/${BBL_STATE_DIR}"
performance_test_results="${task_root}/performance-test-results"

echo -e "\nGetting test landscape configuration from bbl state..."
pushd "$bbl_state" >/dev/null
  eval "$(bbl print-env)"
  bosh_director_name="$(<bbl-state.json jq --raw-output '.bosh.directorName')"
  cf_admin_password="$(credhub get --name "/${bosh_director_name}/cf/cf_admin_password" --output-json | jq --raw-output '.value')"
  cf_domain="$(<bbl-state.json jq --raw-output '.lb.domain')"
  jumpbox_url="$(<./vars/jumpbox-vars-file.yml yq --raw-output '.external_ip')"
  jumpbox_private_key="$(<./vars/jumpbox-vars-store.yml yq --raw-output '.jumpbox_ssh.private_key')"
  database_ip="$(bosh -d cf vms --json | jq --raw-output '.Tables[0].Rows[] | select(.instance | startswith("database/")) | .ips')"
  ccdb_password="$(credhub get --name "/${bosh_director_name}/cf/cc_database_password" --output-json | jq --raw-output '.value')"
  uaadb_password="$(credhub get --name "/${bosh_director_name}/cf/uaa_database_password" --output-json | jq --raw-output '.value')"
popd >/dev/null

echo -e "\nGetting cf-deployment version..."
cf_deployment_version="$(<"${cf_deployment_repo}"/cf-deployment.yml yq '.manifest_version' -r)"
capi_version="$(<"${cf_deployment_repo}"/cf-deployment.yml grep -A 1 capi | grep version | cut -d ':' -f2 | sed 's/ //g')"

echo -e "\nLogging in to CF and creating a test user..."
cf api --skip-ssl-validation "api.${cf_domain}"
cf auth admin "$cf_admin_password"
cf create-user perf-test-user perf-test-password

if [ "$DATABASE_TYPE" == 'postgres' ]; then
  database_port=5524
  database_ccdb="postgres://cloud_controller:${ccdb_password}@localhost:${database_port}/cloud_controller?sslmode=disable"
  database_uaadb="postgres://uaa:${uaadb_password}@localhost:${database_port}/uaa?sslmode=disable"
elif [ "$DATABASE_TYPE" == 'mysql' ]; then
  database_port=3306
  database_ccdb="cloud_controller:${ccdb_password}@tcp(localhost:${database_port})/cloud_controller?multiStatements=true"
  database_uaadb="uaa:${uaadb_password}@tcp(localhost:${database_port})/uaa?multiStatements=true"
else
  echo "Task parameter 'DATABASE_TYPE' must be one of 'postgres' or 'mysql' (is: ${DATABASE_TYPE})."
  exit 1
fi

jumpbox_private_key_file="$(mktemp)"
chmod 0600 "$jumpbox_private_key_file"
cat <<EOF > "$jumpbox_private_key_file"
$jumpbox_private_key
EOF

echo -e "\nOpening SSH tunnel to CF database..."
ssh -4 -N -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=30" -o "ServerAliveCountMax=10" -o "IPQoS=throughput" -i "$jumpbox_private_key_file" -L "$database_port":"$database_ip":"$database_port" jumpbox@"$jumpbox_url" &
ssh_pid=$!

echo -e "\nRunning cf-performance tests..."
test_results="${cf_perf_tests_pipeline_repo}/${TEST_RESULTS_FOLDER}"

pushd "$cf_perf_tests_repo" >/dev/null
  cat << EOF > ./config.yml
api: "api.${cf_domain}"
skip_ssl_validation: true
cf_deployment_version: "$cf_deployment_version"
capi_version: "$capi_version"
users:
  admin:
    username: "admin"
    password: "$cf_admin_password"
database_type: "$DATABASE_TYPE"
ccdb_connection: "$database_ccdb"
uaadb_connection: "$database_uaadb"
samples: 10
results_folder: "$test_results"
EOF
  if [ -z "${TEST_SUITE_FOLDER:-}" ]; then
    echo -e "\nRunning tests in ${TEST_SUITE_FOLDER}..."
    ginkgo ./...
  else
    echo -e "\nRunning all tests..."
    ginkgo -r "$TEST_SUITE_FOLDER"
  fi
popd >/dev/null

echo -e "\n Installing git lfs"
apt-get update && apt-get -y install git-lfs
git lfs install

if [[ $(git -C "$cf_perf_tests_pipeline_repo" status --porcelain) ]]; then
  echo -e "\nCommitting test results..."
  git -C "$cf_perf_tests_pipeline_repo" config user.name "${GIT_COMMIT_USERNAME}"
  git -C "$cf_perf_tests_pipeline_repo" config user.email "${GIT_COMMIT_EMAIL}"
  git -C "$cf_perf_tests_pipeline_repo" add --all "$test_results"
  git -C "$cf_perf_tests_pipeline_repo" commit -m "${GIT_COMMIT_MESSAGE}"
fi

echo "Killing background ssh tunnel..."
kill "$ssh_pid"

cp -r "${cf_perf_tests_pipeline_repo}/." "${performance_test_results}/"

echo -e "\nFinished."
