#!/bin/bash

# Check if a file was passed as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <env-file>"
  exit 1
fi

ENV_FILE="$1"

# Check if file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "File not found: $ENV_FILE"
  exit 1
fi

# Read the file line-by-line
while IFS='=' read -r key value; do
  # Trim whitespace
  key=$(echo "$key" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Ignore blank lines and comments
  [[ -z "$key" || "$key" =~ ^# ]] && continue

  # Export the variable
  export "$key=$value"
done < "$ENV_FILE"
