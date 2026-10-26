#!/bin/bash
set -e

sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias scratch-test --duration-days 30 --wait 10

sf package install --package 04tkP0000006XPVQA2 --target-org scratch-test --wait 10 --no-prompt
sf project deploy start --target-org scratch-test --wait 10
RESULT=$(sf data import tree --files data/bruce-wayne.json --target-org scratch-test --json)
ACCOUNT_ID=$(echo "$RESULT" | jq -r '.result[0].id')
sf org open --target-org scratch-test --path "/lightning/r/Account/$ACCOUNT_ID/view"
