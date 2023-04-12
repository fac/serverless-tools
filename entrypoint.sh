#!/bin/sh

# `$*` expands the `args` supplied in an `array` individually
# or splits `args` in a string separated by whitespace.
echo ">>> Running serverless-tools"

# The following config is required to use the git
# client within Github Actions. For more information,
# see here: https://github.com/fac/serverless-tools/issues/120
git config --global --add safe.directory "$GITHUB_WORKSPACE"

sh -c "serverless-tools $*"
