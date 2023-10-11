#!/bin/bash
set -euo pipefail

wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt update && sudo apt install golang git cf8-cli -y

sudo chown -R $(whoami):$(whoami) /tmp

pushd "/tmp" >/dev/null
    sudo tar -xzvf cf-performance-tests.tar.gz

    pushd "cf-performance-tests" >/dev/null
    if [ -z "${TEST_SUITE_FOLDER:-}" ]; then
        echo -e "\nRunning all tests..."
        go run github.com/onsi/ginkgo/v2/ginkgo run --timeout $GINKGO_TIMEOUT ./...
    else
        echo -e "\nRunning tests in ${TEST_SUITE_FOLDER}..."
        go run github.com/onsi/ginkgo/v2/ginkgo run --timeout $GINKGO_TIMEOUT -r "$TEST_SUITE_FOLDER"
    fi
    popd >/dev/null

    tar -czvf results.tar.gz results
popd >/dev/null