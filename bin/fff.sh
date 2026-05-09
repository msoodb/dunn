#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <urls-file>" >&2
  exit 1
fi

URLS=$1

if [[ ! -f "$URLS" ]]; then
  echo "Error: file not found: $URLS" >&2
  exit 1
fi

if ! command -v fff >/dev/null 2>&1; then
  echo "Error: fff not found in PATH" >&2
  exit 1
fi

name=$(basename "$URLS")
name=${name//[^A-Za-z0-9._-]/_}
out_dir="fff_${name}"
filtered=$(mktemp)

trap 'rm -f "$filtered"' EXIT

grep -Ev '^[[:space:]]*($|#)' "$URLS" > "$filtered"

if [[ ! -s "$filtered" ]]; then
  echo "Error: no URLs left after removing empty lines and comments" >&2
  exit 1
fi

fff -d 1 -S -o "$out_dir" < "$filtered"
