#!/bin/bash

# Script to update Maven POM.xml versions using XSLT
# Usage: ./update_pom_versions.sh <new_version> [pom_file]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <new_version> [pom_file]"
    echo "Example: $0 1.2.3-SNAPSHOT"
    echo "Example: $0 1.2.3-SNAPSHOT custom-pom.xml"
    exit 1
fi

NEW_VERSION="$1"
POM_FILE="${2:-pom.xml}"

if [ ! -f "$POM_FILE" ]; then
    echo "Error: POM file '$POM_FILE' not found"
    exit 1
fi

# Check if required tools are available
if ! command -v xsltproc &> /dev/null; then
    echo "Error: xsltproc is not installed. Please install it using:"
    echo "  Ubuntu/Debian: sudo apt-get install xsltproc"
    echo "  CentOS/RHEL: sudo yum install libxslt"
    echo "  macOS: brew install libxslt"
    exit 1
fi

echo "Updating POM versions to: $NEW_VERSION"
echo "Target file: $POM_FILE"

# Create temporary XSLT transformation file
XSLT_FILE=$(mktemp --suffix=.xsl)
trap "rm -f $XSLT_FILE" EXIT

cat > "$XSLT_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="newVersion"/>
    
    <!-- Identity template - copy everything as is -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Update the parent version -->
    <xsl:template match="project/parent/version">
        <version><xsl:value-of select="$newVersion"/></version>
    </xsl:template>
    
    <!-- Update common-domain-version -->
    <xsl:template match="common-domain-version">
        <common-domain-version><xsl:value-of select="$newVersion"/></common-domain-version>
    </xsl:template>
</xsl:stylesheet>
EOF

# Create temporary output file
TEMP_POM=$(mktemp --suffix=.xml)
trap "rm -f $XSLT_FILE $TEMP_POM" EXIT

# Apply XML transformation
if xsltproc --stringparam newVersion "$NEW_VERSION" "$XSLT_FILE" "$POM_FILE" > "$TEMP_POM"; then
    # Replace the original file only if transformation succeeded
    mv "$TEMP_POM" "$POM_FILE"
    echo "Successfully updated $POM_FILE"
else
    echo "Error: Failed to transform $POM_FILE"
    exit 1
fi

# Validate the resulting XML
if command -v xmllint &> /dev/null; then
    if xmllint --noout "$POM_FILE" 2>/dev/null; then
        echo "XML validation: PASSED"
    else
        echo "Warning: Generated XML may not be well-formed"
    fi
fi

echo "POM version update completed successfully"
