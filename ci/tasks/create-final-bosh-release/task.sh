#!/bin/bash

set -euo pipefail

cd cf-performance-tests-release
bosh create-release --final --tarball=releases/cf-performance-errand.tgz

git add .
git config --global user.name "testname"
git config --global user.email "test@sap.com"
git commit -m "Final BOSH release"
echo "Finished creating BOSH release."
