#!/bin/bash

set -e

KEYWORD="$1"
DATE_TAG="$2"

# Extract version prefix from pom.xml (e.g., 5.30.0 from 5.30.0-RC.2)
VERSION_PREFIX=$(xmllint --xpath 'string(//project/version)' pom.xml | cut -d'-' -f1)

# Construct base of the tag
BASE_TAG="${VERSION_PREFIX}-${KEYWORD}-${DATE_TAG}"

# Determine the next alpha index by checking existing tags
EXISTING_TAGS=$(git tag --list "${BASE_TAG}-alpha.*")
if [[ -z "$EXISTING_TAGS" ]]; then
  INDEX=1
else
  LAST_INDEX=$(echo "$EXISTING_TAGS" | grep -o 'alpha\.[0-9]*' | cut -d. -f2 | sort -nr | head -n1)
  INDEX=$((LAST_INDEX + 1))
fi

# Final tag
TAG_NAME="${BASE_TAG}-alpha.${INDEX}"
echo "$TAG_NAME" > .tag_name
