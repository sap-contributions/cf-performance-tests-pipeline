#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
test_results_folder="${task_root}${TEST_RESULTS_FOLDER}"
generated_charts_absolute_path="${cf_perf_tests_pipeline_repo}/${GENERATED_CHARTS_FOLDER}"

echo -e "\nInstalling matplotlib..."
pip install matplotlib

mkdir -p "$generated_charts_absolute_path"

echo -e "\nGenerating charts..."
python "${cf_perf_tests_pipeline_repo}/ci/tasks/generate-charts/generate_charts.py" \
  --test-results "$test_results_folder" --generated-charts "$generated_charts_absolute_path"

echo -e "\n Installing git lfs"
apt-get update && apt-get -y install git-lfs
git lfs install

if [[ $(git -C "$cf_perf_tests_pipeline_repo" status --porcelain) ]]; then
  echo -e "\nCommitting generated charts..."
  git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
  git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
  git -C "$cf_perf_tests_pipeline_repo" add --all "$generated_charts_absolute_path"
  git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
fi

echo "Finished."
