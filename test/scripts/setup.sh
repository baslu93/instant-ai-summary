#!/bin/bash
set -e

MODE=${1:-source}
PACKAGE_ID=04tkP0000006XyzQAE

if [[ "$MODE" != "source" && "$MODE" != "package" ]]; then
  echo "Usage: $0 [source|package]"
  exit 1
fi

sf org create scratch \
  --definition-file test/config/project-scratch-def.json \
  --alias scratch-test --duration-days 30 --wait 10

if [[ "$MODEw" == "package" ]]; then
  sf package install --package $PACKAGE_ID --target-org scratch-test --wait 10 --no-prompt
else
  sf project deploy start --target-org scratch-test --wait 10
fi

sf project deploy start --source-dir test/default --target-org scratch-test --wait 10
echo "UserFactory.create();" | sf apex run --target-org scratch-test

RESULT=$(sf data import tree --files data/bruce-wayne.json --target-org scratch-test --json)
ACCOUNT_ID=$(echo "$RESULT" | jq -r '.result[0].id')
sf org open --target-org scratch-test --path "/lightning/r/Account/$ACCOUNT_ID/view"
