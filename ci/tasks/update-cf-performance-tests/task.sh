#!/bin/bash

set -euo pipefail

cd cf-performance-tests-release
pushd src/cf-performance-tests >/dev/null
  git pull origin main --ff-only
  commit_message="$(git log --format="%h %s" -1)"
popd >/dev/null

git add ./src/cf-performance-tests
git config --global user.name "testname"
git config --global user.email "test@sap.com"
git commit -m "$commit_message"
echo "Finished updating submodule."