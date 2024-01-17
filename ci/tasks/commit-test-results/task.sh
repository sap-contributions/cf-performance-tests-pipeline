#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
bbl_state="${task_root}/bbl-state/${BBL_STATE_DIR}"

echo -e "\nInitializing BOSH environment from bbl state..."
pushd "$bbl_state" >/dev/null
  eval "$(bbl print-env)"
popd >/dev/null

echo -e "\nDownloading test results from errand VM..."
bosh -d cf scp cf-performance-tests-errand/0:/tmp/results.tar.gz "${cf_perf_tests_pipeline_repo}/results.tar.gz"
pushd "$cf_perf_tests_pipeline_repo" >/dev/null
  tar -xzvf results.tar.gz
  rm -rf results.tar.gz
popd >/dev/null

echo -e "\nInstalling git lfs..."
apt-get update && apt-get -y install git-lfs
git lfs install

if [[ $(git -C "$cf_perf_tests_pipeline_repo" status --porcelain) ]]; then
  echo -e "\nCommitting test results..."
  git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
  git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
  git -C "$cf_perf_tests_pipeline_repo" add --all "$cf_perf_tests_pipeline_repo/results"
  git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
fi

echo -e "\nFinished."
