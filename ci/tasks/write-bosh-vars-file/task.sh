#!/bin/bash

set -euo pipefail

yq --yaml-output <<< "$VARS" > vars-file/cf-vars.yml