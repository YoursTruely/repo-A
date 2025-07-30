#!/bin/bash

KEYWORD="$1"
DATE_TAG="$2"

# Default fallback version
VERSION_PREFIX="0.0.0"

if [ -f "pom.xml" ]; then
  VERSION_PREFIX=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='version']/text()" pom.xml 2>/dev/null || echo "0.0.0")
fi

# Remove suffix (e.g., -RC.2) if present
VERSION_PREFIX=$(echo "$VERSION_PREFIX" | sed 's/-.*//')

# Construct suffix base
SUFFIX_BASE="$KEYWORD-EOL-$DATE_TAG-alpha"

# Find next available alpha tag number
INDEX=1
while git tag | grep -q "${VERSION_PREFIX}-${SUFFIX_BASE}.${INDEX}"; do
  INDEX=$((INDEX + 1))
done

TAG_NAME="${VERSION_PREFIX}-${SUFFIX_BASE}.${INDEX}"
echo "$TAG_NAME" > .tag_name
