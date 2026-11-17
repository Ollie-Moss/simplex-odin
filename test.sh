#!/bin/bash

set -e

if [ $# -eq 0 ]; then
    test_names=""
else
    test_names="-define:ODIN_TEST_NAMES=$(IFS=,; echo "$*")"
fi

odin test "tests/" -all-packages -collection:simplex=./src "$test_names"
