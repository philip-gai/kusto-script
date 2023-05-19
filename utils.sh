#!/bin/bash

function get_auth_string() {
  set -e

  uri=$1
  tenant=$2

  if [ -z "$uri" ] || [ -z "$tenant" ]; then
    echo "uri and tenant are required"
    exit 1
  fi

  # Get user token from az cli
  echo "Getting Access token to $uri"
  token=$(az account get-access-token --resource=$uri --query accessToken --output tsv)
  echo "::add-mask::$token"

  if [ -z "$token" ]; then
    echo "Failed to get access token"
    exit 1
  fi

  auth="Fed=true;AppToken=$token;"

  if [ ! -z "$tenant" ]; then
    echo "Using Authority Id $tenant"
    auth+="Authority Id=$tenant;"
  fi

  echo "auth=$auth"

  return $auth
}
