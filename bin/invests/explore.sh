#!/bin/bash

#while true; do clear; tree -a -L ${1:-2}; sleep 2; done

# Default depth level
DEPTH=${1:-2}

# Ensure DEPTH is a valid number
if ! [[ $DEPTH =~ ^[0-9]+$ ]]; then
  echo "Error: Depth must be a positive integer."
  exit 1
fi

# Handle graceful exit
trap "echo; echo 'Exiting...'; exit 0" SIGINT SIGTERM

# Monitor directory structure
while true; do
  clear
  tree -a -L "$DEPTH"
  sleep 2
done
