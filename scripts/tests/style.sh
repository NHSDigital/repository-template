#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"


# This file is for you! Edit it to call your prose style checker.
# It's preconfigured to use `vale`, the same as the GitHub action,
# and currently runs via pre-commit against all files for consistency
# with CI checks.

prek run check-english-usage --all-files
