#!/bin/bash
set -e

# Harmonization Script: AWS Team Style
# This script applies the following rules:
# 1. Use Tabs for indentation in .tf files (2 spaces -> 1 tab).
# 2. Remove spaces around assignment '=' in .tf files (e.g., key=value).
# 3. Standardize YAML files to 4-space indentation (increments of 4).

TARGET_DIR=${1:-"."}

echo "Starting harmonization of ${TARGET_DIR} to AWS Team standards."

# 1. Process Terraform files
echo "Formatting Terraform files (.tf)."
find "$TARGET_DIR" -name "*.tf" -not -path "*/.terraform/*" | while read -r file; do
    # Convert leading spaces to tabs (2 spaces = 1 tab)
    perl -i -pe '1 while s/^(\t*)  /$1\t/' "$file"
    
    # Remove spaces around assignment '='
    # Regex ensures we don't touch '==', '!=', '>=', '<='
    sed -i -E 's/([^!<>=\s]) *= *([^=])/\1=\2/g' "$file"
done

# 2. Process YAML files
echo "Formatting YAML files (.yaml, .yml)."
# Use Perl for accurate indentation transformation.
# This logic doubles the leading spaces (2 -> 4, 4 -> 8, etc.) 
# to ensure consistent 4-space increments for files that were originally 2-space.
# It also ensures no tabs are present in YAML files.
find "$TARGET_DIR" \( -name "*.yaml" -o -name "*.yml" \) -not -path "*/.terraform/*" | while read -r file; do
    # Convert 2-space increments to 4-space increments
    # This logic only scales EXISTING indentation correctly.
    # We use a pattern that doubles the leading space count.
    perl -i -pe 's/^(\s+)/" " x (length($1) * 2)/e' "$file"
    
    # Ensure no tabs in YAML (YAML forbids them)
    sed -i 's/\t/    /g' "$file"
done

echo "Harmonization complete!"
echo "Note: This formatting is non-standard for OpenTofu/Terraform."
echo "Running \"tofu fmt\" will revert these changes."
