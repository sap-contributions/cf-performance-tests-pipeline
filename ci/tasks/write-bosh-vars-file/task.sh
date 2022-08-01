#!/bin/bash

set -euo pipefail

yq --yaml-output <<< "$VARS" > cf-vars-file/cf-vars.yml