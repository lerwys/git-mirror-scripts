#!/bin/bash

# Setup a Git mirror with a remote repository.

set -e

usage () {
    echo "Usage:" >&2
    echo "  ${1} -o ORIGIN_REPO_URL -t TARGET_REPO_URL -l REPO_PATH" >&2
    echo >&2
    echo " Options:" >&2
    echo "  -o                  Origin repository URL" >&2
    echo "  -t                  Target repository URL" >&2
    echo "  -p                  Path to clone repository (i.e., /tmp/repo_name)" >&2
}

while getopts ":o:t:p:" opt; do
  case ${opt} in
    o) ORIGIN_REPO_URL="${OPTARG}" ;;
    t) TARGET_REPO_URL="${OPTARG}" ;;
    p) REPO_PATH="${OPTARG}" ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      usage ${0}
      exit 1
      ;;
    :)
      echo "Option -${OPTARG} requires an argument." >&2
      usage ${0}
      exit 1
      ;;
  esac
done

# Check if getopts did not process all input
if [ "${OPTIND}" -le "$#" ]; then
    echo "Invalid argument at index '${OPTIND}' does not have a corresponding option." >&2
    usage ${0}
    exit 1
fi

# Check if mandatory options were used
if [ -z "${ORIGIN_REPO_URL}" ]; then
    echo "\${ORIGIN_REPO_URL} is not set, Please use -o option" >&2
    exit 1
fi

if [ -z "${TARGET_REPO_URL}" ]; then
    echo "\${TARGET_REPO_URL} is not set, Please use -t option" >&2
    exit 1
fi

if [ -z "${REPO_PATH}" ]; then
    echo "\${REPO_PATH} is not set, Please use -p option" >&2
    exit 1
fi

set -euo pipefail

git clone --mirror "${ORIGIN_REPO_URL}" "${REPO_PATH}"
git --git-dir ${REPO_PATH} remote set-url --push origin ${TARGET_REPO_URL}

echo "Mirror for ${ORIGIN_REPO_URL} successfully set up in ${REPO_PATH}."
echo "Add the following to a cronjob to synchronize the mirror:"

echo "git --git-dir ${REPO_PATH} fetch -p origin && git --git-dir ${REPO_PATH} push --mirror"
