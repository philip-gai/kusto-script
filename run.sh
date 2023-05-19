#!/bin/bash

set -e

# Path to this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

source "$DIR/functions.sh"

while getopts f:q:s:t:u: flag; do
    case "${flag}" in
    f) folders=${OPTARG} ;;
    q) query=${OPTARG} ;;
    s) script_relativepath=${OPTARG} ;;
    t) tenant=${OPTARG} ;;
    u) uri=${OPTARG} ;;
    esac
done

if [ -z "$KUSTO_CLI_PATH" ]; then
    echo "KUSTO_CLI_PATH is not set"
    exit 1
fi

auth=$(get_auth_string $uri $tenant)
connectionString="$uri;$auth"

echo "Connection string: $connectionString"

if [ ! -z "$folders"]; then
    result=""
    for folder in $folders; do
        echo "Processing folder: $folder"
        result+=$(deploy_files_recursive "$folder")
    done
elif [ ! -z "$query" ]; then
    result=$(execute_query "$query" "$connectionString")
elif [ ! -z "$script_relativepath" ]; then
    script_fullpath="$GITHUB_WORKSPACE/$script_relativepath"
    result=$(execute_script "$script_fullpath" "$connectionString")
else
    echo "No query or script provided"
    exit 1
fi

echo "$result"

if [ ! -z "$CI" ]; then
    # EOF needed for multiline output
    echo "result<<EOF" >>$GITHUB_OUTPUT
    echo "$result" >>$GITHUB_OUTPUT
    echo "EOF" >>$GITHUB_OUTPUT
    echo "$result" >>$GITHUB_STEP_SUMMARY
fi
