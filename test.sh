#!/bin/bash

set -e 

odin test "tests/" -all-packages -collection:simplex=./src 
