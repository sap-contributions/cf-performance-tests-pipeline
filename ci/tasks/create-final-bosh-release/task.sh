#!/bin/bash

set -euo pipefail

cd cf-performance-tests-release

echo "$PRIVATE_YML" > config/private.yml

bosh vendor-package cf-cli-8-linux ../bosh-package-cf-cli-release
bosh vendor-package golang-1.21-linux ../bosh-package-golang-release
if [ -z "$(git status --porcelain=v1 2>/dev/null)" ]; then
  echo "No changes in vendored packages to commit."
else
  git add .
  git config --global user.name "$GIT_COMMIT_USERNAME"
  git config --global user.email "$GIT_COMMIT_EMAIL"
  git commit -m "Update vendored packages"
  echo "Updated vendored packages."
fi

bosh create-release --final --tarball=../cf-performance-tests-release-output/cf-performance-errand.tgz

git add .
git config --global user.name "$GIT_COMMIT_USERNAME"
git config --global user.email "$GIT_COMMIT_EMAIL"
git commit -m "Final BOSH release"
echo "Finished creating BOSH release."
