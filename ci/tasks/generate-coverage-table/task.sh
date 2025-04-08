#!/bin/bash

set -euo pipefail

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
results_dir="${cf_perf_tests_pipeline_repo}/results"
coverage_file="${cf_perf_tests_pipeline_repo}/${COVERAGE_TABLE_FILE}"

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pip install -r "${script_dir}/requirements.txt"

python "${cf_perf_tests_pipeline_repo}/ci/tasks/generate-coverage-table/generate-coverage-table.py" \
  --results-root-dir "$results_dir" \
  --output-file "$coverage_file"

pushd "${cf-performance-tests-pipeline}" > /dev/null
  if [[ $(git diff --exit-code "${coverage_file}") ]]; then
    echo -e "\nNo changes in coverage.md file: ${coverage_file}"
  else
    echo -e "\nCommitting coverage table..."
    git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
    git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
    git -C "$cf_perf_tests_pipeline_repo" add "$coverage_file"
    git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
  fi
popd > /dev/null

echo "Finished."
