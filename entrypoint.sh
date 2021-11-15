#!/bin/sh

# `$*` expands the `args` supplied in an `array` individually
# or splits `args` in a string separated by whitespace.
echo ">>> Running serverless-tools"
sh -c "serverless-tools $*"
