#!/bin/bash

function get_auth_string() {
  uri=$1
  tenant=$2

  if [ -z "$uri" ]; then
    echo "Usage: get_auth_string <uri> <tenant>" >&2
    return 1
  fi

  # Remove anything after the last '/' in the uri
  num_forward_slashes=$(grep -o '/' <<<"$uri" | grep -c .)
  if [ $num_forward_slashes -gt 2 ]; then
    uri="${uri%/*}"
  fi

  # Get user token from az cli
  echo "Getting Access token to $uri" >&2
  token=$(az account get-access-token --resource=$uri --query accessToken --output tsv)

  if [ -z "$token" ]; then
    echo "Failed to get access token" >&2
    return 1
  fi

  if [ ! -z "$CI" ]; then
    echo "::add-mask::$token" >&2
  fi
  auth="Fed=true;AppToken=$token;"

  if [ ! -z "$tenant" ]; then
    echo "Using Authority Id $tenant" >&2
    auth+="Authority Id=$tenant;"
  fi

  echo "$auth"
}

function deploy_files_recursive() {
  folder=$1
  connectionString=$2
  result=$3

  if [ -z "$folder" ] || [ -z "$connectionString" ]; then
    echo "Usage: deploy_files_recursive <folder> <connectionString>" >&2
    return 1
  fi

  if [ -z "$KUSTO_CLI_PATH" ]; then
    echo "KUSTO_CLI_PATH environment variable is not set" >&2
    return 1
  fi

  for file in "$folder"/*; do
    if [ -d "$file" ]; then
      deploy_files_recursive "$file" "$connectionString" "$result"
    else
      echo "Deploying file $file" >&2
      result+=$(execute_script "$file" "$connectionString")
    fi
  done

  echo "$result"
}

function execute_script() {
  script_fullpath=$1
  connectionString=$2

  if [ -z "$script_fullpath" ] || [ -z "$connectionString" ]; then
    echo "Usage: execute_script <script_fullpath> <connectionString>" >&2
    return 1
  fi

  if [ -z "$KUSTO_CLI_PATH" ]; then
    echo "KUSTO_CLI_PATH environment variable is not set" >&2
    return 1
  fi

  echo "Executing script: $script_fullpath" >&2

  # Automatically add #markdownon to the top of the script to format output
  echo -e "#markdownon\n" | cat - $script_fullpath >/tmp/out && mv /tmp/out $script_fullpath

  result=$(dotnet $KUSTO_CLI_PATH "$connectionString" \
    -lineMode:false \
    -script:"$script_fullpath")
  echo "$result"
}

function execute_query() {
  query=$1
  connectionString=$2

  if [ -z "$query" ] || [ -z "$connectionString" ]; then
    echo "Usage: execute_query <query> <connectionString>" >&2
    return 1
  fi

  if [ -z "$KUSTO_CLI_PATH" ]; then
    echo "KUSTO_CLI_PATH environment variable is not set" >&2
    return 1
  fi

  echo "Executing query: \"$query\"" >&2
  result=$(dotnet $KUSTO_CLI_PATH "$connectionString" \
    -execute:"#markdownon" \
    -execute:"$query")

  echo "$result"
}
