#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Missing argument!"
    echo "Usage: build.sh <example>"
    exit 1
fi

DIR="examples/$1"

if [ ! -d "$DIR" ]; then
    echo "Error: Example directory '$DIR' does not exist."
    exit 1
fi

# Exit on any error
set -e

echo "Building..."
odin run "$DIR/" --collection:simplex=./src -o:speed
