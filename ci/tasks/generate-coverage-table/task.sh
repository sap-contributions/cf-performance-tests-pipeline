#!/bin/bash

set -xeuo pipefail

task_root="$(pwd)"
cf_perf_tests_pipeline_repo="${task_root}/cf-performance-tests-pipeline"
results_repo="${task_root}/results"
results_folder="${results_repo}/results"
coverage_file="${results_folder}/${COVERAGE_TABLE_FILE}"

script_dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
pip install -r "${script_dir}/requirements.txt"

python "${cf_perf_tests_pipeline_repo}/ci/tasks/generate-coverage-table/generate-coverage-table.py" \
  --results-root-dir "${results_folder}" \
  --output-file "${coverage_file}"

pushd "${results_folder}" > /dev/null
  if [[ $(git diff --exit-code "${COVERAGE_TABLE_FILE}") ]]; then
    echo -e "\nNo changes in coverage.md file: ${COVERAGE_TABLE_FILE}"
  else
    echo -e "\nCommitting coverage table..."
    git -C "$cf_perf_tests_pipeline_repo" config user.name "$GIT_COMMIT_USERNAME"
    git -C "$cf_perf_tests_pipeline_repo" config user.email "$GIT_COMMIT_EMAIL"
    git -C "$cf_perf_tests_pipeline_repo" add "${COVERAGE_TABLE_FILE}"
    git -C "$cf_perf_tests_pipeline_repo" commit -m "$GIT_COMMIT_MESSAGE"
  fi
popd > /dev/null

echo "Finished."
