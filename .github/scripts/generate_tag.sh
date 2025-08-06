#!/bin/bash

KEYWORD="$1"
DATE_TAG="$2"

# Check for pom.xml presence
if [ ! -f "pom.xml" ]; then
  echo "[ERROR] pom.xml not found. Aborting tag generation."
  exit 1
fi

# Try to extract version
VERSION_PREFIX=$(xmllint --xpath "/*[local-name()='project']/*[local-name()='version']/text()" pom.xml 2>/dev/null)

if [ -z "$VERSION_PREFIX" ]; then
  echo "[ERROR] Failed to extract <version> from pom.xml. Aborting."
  exit 1
fi

# Strip suffix like -RC.2
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
echo "[INFO] Generated tag: $TAG_NAME"
