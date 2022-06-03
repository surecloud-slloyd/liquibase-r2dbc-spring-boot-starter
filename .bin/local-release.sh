#!/usr/bin/env bash

###
# bash .bin/local-release.sh
###

ARGS=${1:-}
ROOT_PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cd "${ROOT_PROJECT_DIR}" && ./mvnw -B -P local-release ${ARGS}

cd "${ROOT_PROJECT_DIR}" && git fetch --all -p -a --tags

#cd "${ROOT_PROJECT_DIR}" && ./mvnw -DskipTests install