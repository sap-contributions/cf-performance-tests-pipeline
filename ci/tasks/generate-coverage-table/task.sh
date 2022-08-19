#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
results_dir="${cf_perf_tests_pipeline_repo}/results"
coverage_file="${cf_perf_tests_pipeline_repo}/${COVERAGE_TABLE_FILE}"

pip install -r "${script_dir}/requirements.txt"

python "${cf_perf_tests_pipeline_repo}/ci/tasks/generate-coverage-table/generate-coverage-table.py" \
  --results-root-dir "$results_dir" \
  --output-file "$coverage_file"

if [[ $(git -C "$cf_perf_tests_pipeline_repo" status --porcelain) ]]; then
  echo -e "\nCommitting coverage table..."
  git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
  git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
  git -C "$cf_perf_tests_pipeline_repo" add "$coverage_file"
  git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
fi

echo "Finished."
