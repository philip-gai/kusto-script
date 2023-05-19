#!/bin/bash

set -e

source utils.sh

while getopts q:s:t:u: flag; do
    case "${flag}" in
    q) query=${OPTARG} ;;
    s) script=${OPTARG} ;;
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

if [ ! -z "$query" ]; then
    echo "Executing query: \"$query\""
    result=$(dotnet $KUSTO_CLI_PATH "$connectionString" \
        -execute:"#markdownon" \
        -execute:"$query")
elif [ ! -z "$script" ]; then
    script_fullpath="$GITHUB_WORKSPACE/user-scripts/$script"
    echo "Executing script: $script_fullpath"

    # Automatically add #markdownon to the top of the script to format output
    echo -e "#markdownon\n" | cat - $script_fullpath >/tmp/out && mv /tmp/out $script_fullpath

    result=$(dotnet $KUSTO_CLI_PATH "$connectionString" \
        -lineMode:false \
        -script:"$script_fullpath")
else
    echo "No query or script provided"
    exit 1
fi

echo "$result"
echo "result=$result" >>$GITHUB_OUTPUT
