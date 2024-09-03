#!/bin/bash

set -euo pipefail

# Pre-commit git hook to sort the Vale dictionary in a consistent manner to avoid future merge conflicts and aid insertion of new terms
#
# Usage:
#   $ [options] ./sort-dictionary.sh
#
# Options:
#
#
# Exit codes:
#   0 - Successfully sorted the dictionary
#   non-zero - failed to sort dictionary

# ==============================================================================

function main() {
  root=scripts/config/vale/styles/config/vocabularies/words
  opts="--dictionary-order --ignore-case -s"
  sort $opts $root/accept.txt > $root/accept.sorted.txt
  sort $opts $root/reject.txt > $root/reject.sorted.txt

  mv $root/accept.sorted.txt $root/accept.txt
  mv $root/reject.sorted.txt $root/reject.txt

  git add -uv $root/*
}

# ==============================================================================

function is-arg-true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is-arg-true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
