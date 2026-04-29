#!/bin/bash

# Define project name
PROJECT_NAME=$1
PROJECT_PREFIX=$2

# Define directories
DIRS=(
    "$PROJECT_NAME/src"
    "$PROJECT_NAME/include"
    "$PROJECT_NAME/logs"
    "$PROJECT_NAME/config"
    "$PROJECT_NAME/tests"
)

# Define files
FILES=(
    "$PROJECT_NAME/src/$PROJECT_NAME.c"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_capture.c"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_capture.h"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_logger.c"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_logger.h"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_process.c"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_process.h"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_utils.c"
    "$PROJECT_NAME/src/$PROJECT_PREFIX_utils.h"
    "$PROJECT_NAME/Makefile"
    "$PROJECT_NAME/README.md"
    "$PROJECT_NAME/LICENSE"
)

# Create directories
echo "Creating project directories..."
for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
done

# Create files
echo "Creating project files..."
for file in "${FILES[@]}"; do
    touch "$file"
done

# Add basic content to Makefile
cat <<EOL > "$PROJECT_NAME/Makefile"
CC = gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -lpcap

SRC = src/main.c src/capture.c src/logger.c src/process.c src/utils.c
OBJ = \$(SRC:.c=.o)
TARGET = portspy

all: \$(TARGET)

\$(TARGET): \$(OBJ)
	\$(CC) \$(CFLAGS) \$(OBJ) -o \$(TARGET) \$(LDFLAGS)

clean:
	rm -f \$(OBJ) \$(TARGET)

.PHONY: all clean
EOL

# Add a basic README.md
cat <<EOL > "$PROJECT_NAME/README.md"
# $PROJECT_NAME

$PROJECT_NAME is a lightweight Linux tool written in C for monitoring a specific network port and logging all traffic.

## Features
- Captures incoming and outgoing traffic on a specified port
- Logs traffic details including source/destination, payload (optional), and timestamp
- Maps network connections to process IDs

## Build
Run the following command to compile the project:
\`\`\`
make
\`\`\`

## Usage
\`\`\`
./$PROJECT_NAME -p <port> -o logs/output.log
\`\`\`
EOL

# Done
echo "Project structure for '$PROJECT_NAME' has been created successfully!"
