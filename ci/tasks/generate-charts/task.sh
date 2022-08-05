#!/bin/bash

set -euo pipefail

repo="$(pwd)/cf-performance-tests-pipeline"

echo -e "\nInstalling matplotlib..."
pip install matplotlib

if [ -z "$TEST_RESULTS_FOLDER" ]; then
  echo "Task parameter 'TEST_RESULTS_FOLDER' is empty. Check pipeline configuration."
  exit 1
fi
if [ -z "$GENERATED_CHARTS_FOLDER" ]; then
  echo "Task parameter 'GENERATED_CHARTS_FOLDER' is empty. Check pipeline configuration."
  exit 1
fi
mkdir -p "$GENERATED_CHARTS_FOLDER"

echo -e "\nGenerating charts..."
python "${repo}/ci/tasks/generate-charts/generate_charts.py" \
  --test-results "$TEST_RESULTS_FOLDER" --generated-charts "$GENERATED_CHARTS_FOLDER"

echo -e "\n Installing git lfs"
apt-get update && apt-get -y install git-lfs
git lfs install

if [[ $(git -C "$repo" status --porcelain) ]]; then
  echo -e "\nCommitting generated charts..."
  git -C "$repo" config user.name "$GIT_COMMIT_USERNAME"
  git -C "$repo" config user.email "$GIT_COMMIT_EMAIL"
  git -C "$repo" add "$GENERATED_CHARTS_FOLDER"
  git -C "$repo" commit -m "$GIT_COMMIT_MESSAGE"
fi

echo "Finished."
