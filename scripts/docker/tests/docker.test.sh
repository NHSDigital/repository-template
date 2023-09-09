#!/bin/bash
# shellcheck disable=SC1091,SC2034,SC2317

# WARNING: Please, DO NOT edit this file! It is maintained in the Repository Template (https://github.com/nhs-england-tools/repository-template). Raise a PR instead.

set -euo pipefail

# Test suite for Docker functions.
#
# Usage:
#   $ ./docker.test.sh
#
# Arguments (provided as environment variables):
#   VERBOSE=true  # Show all the executed commands, default is 'false'

# ==============================================================================

function main() {

  cd "$(git rev-parse --show-toplevel)"
  source ./scripts/docker/docker.lib.sh
  cd ./scripts/docker/tests

  DOCKER_IMAGE=repository-template/docker-test
  DOCKER_TITLE="Repository Template Docker Test"

  test-docker-suite-setup
  tests=( \
    test-docker-build \
    test-docker-version \
    test-docker-test \
    test-docker-run \
    test-docker-clean \
  )
  local status=0
  for test in "${tests[@]}"; do
    {
      echo -n "$test"
      # shellcheck disable=SC2015
      $test && echo " PASS" || { echo " FAIL"; ((status++)); }
    }
  done
  echo "Total: ${#tests[@]}, Passed: $(( ${#tests[@]} - status )), Failed: $status"
  test-docker-suite-teardown
  [ $status -gt 0 ] && return 1 || return 0
}

# ==============================================================================

function test-docker-suite-setup() {

  :
}

function test-docker-suite-teardown() {

  :
}

# ==============================================================================

function test-docker-build() {

  # Arrange
  export BUILD_DATETIME="2023-09-04T15:46:34+0000"
  # Act
  docker-build > /dev/null 2>&1
  # Assert
  docker image inspect "${DOCKER_IMAGE}:$(_get-effective-version)" > /dev/null 2>&1 && return 0 || return 1
}

function test-docker-version() {

  # Arrange
  export BUILD_DATETIME="2023-09-04T15:46:34+0000"
  # Act
  version-create-effective-file
  # Assert
  # shellcheck disable=SC2002
  (
      cat .version | grep -q "20230904-" &&
      cat .version | grep -q "2023.09.04-" &&
      cat .version | grep -q "somme-name-yyyyeah"
  ) && return 0 || return 1
}

function test-docker-test() {

  # Arrange
  cmd="python --version"
  check="Python"
  # Act
  output=$(docker-check-test)
  # Assert
  echo "$output" | grep -q "PASS"
}

function test-docker-run() {

  # Arrange
  cmd="python --version"
  # Act
  output=$(docker-run)
  # Assert
  echo "$output" | grep -Eq "Python [0-9]+\.[0-9]+\.[0-9]+"
}

function test-docker-clean() {

  # Arrange
  version="$(_get-effective-version)"
  # Act
  docker-clean
  # Assert
  docker image inspect "${DOCKER_IMAGE}:${version}" > /dev/null 2>&1 && return 1 || return 0
}

# ==============================================================================

function is_arg_true() {

  if [[ "$1" =~ ^(true|yes|y|on|1|TRUE|YES|Y|ON)$ ]]; then
    return 0
  else
    return 1
  fi
}

# ==============================================================================

is_arg_true "${VERBOSE:-false}" && set -x

main "$@"

exit 0
