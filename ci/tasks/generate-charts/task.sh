#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
results_path="${cf_perf_tests_pipeline_repo}/results/${CLOUD_CONTROLLER_TYPE}/${CCDB}/results"
charts_path="${cf_perf_tests_pipeline_repo}/results/${CLOUD_CONTROLLER_TYPE}/${CCDB}/charts"

echo -e "\nInstalling matplotlib..."
pip install matplotlib

mkdir -p "$charts_path" "$results_path"

echo -e "\nGenerating charts..."
python "${cf_perf_tests_pipeline_repo}/ci/tasks/generate-charts/generate_charts.py" \
  --test-results "$results_path" --generated-charts "$charts_path"

echo -e "\n Installing git lfs"
apt-get update && apt-get -y install git-lfs
git lfs install

if [[ $(git -C "$cf_perf_tests_pipeline_repo" status --porcelain) ]]; then
  echo -e "\nCommitting generated charts..."
  git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
  git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
  git -C "$cf_perf_tests_pipeline_repo" add --all "$charts_path"
  git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
fi

echo "Finished."
