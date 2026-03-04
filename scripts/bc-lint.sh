#!/bin/bash

# Brian Chan's Pickiness Linter (bc-lint) v2
# Extracted from liferay-portal commit history

echo "Running Brian Chan's Pickiness Linter v2."
echo "----------------------------------------"

EXIT_CODE=0

# Helper to report failure
fail() {
        echo "FAILED: ${1}"
        EXIT_CODE=1
}

# 1. Check for ellipses in echo/log messages (should end with a single period)
echo "Checking for ellipses in log messages."
grep -rE "echo \".*\.\.\.\"" . --exclude-dir={.git,.terraform} --exclude=bc-lint.sh | grep -v "FIXME" && \
        fail "Found ellipses (...) in log messages. Use a single period (.) instead."

# 2. Check for single quotes used for highlighting in double-quoted strings
echo "Checking for single quotes in double-quoted logs."
grep -rE "echo \".*'.*'.*\"" . --exclude-dir={.git,.terraform} --exclude=bc-lint.sh && \
        fail "Use escaped double quotes (\"\\\") instead of single quotes (') for highlighting inside double-quoted strings."

# 3. Check for subshell spacing before backslash
echo "Checking for subshell spacing."
grep -rE "\$\(\\\\" . --exclude-dir={.git,.terraform} --exclude=bc-lint.sh && \
        fail "Add a space after the opening parenthesis of a subshell if followed by a backslash: \$( \ "

# 4. Check for ArgoCD brand naming in scripts
echo "Checking for ArgoCD brand naming."
find . -name "*.sh" -not -path "*/.git/*" -not -name "bc-lint.sh" | xargs grep -l "argo_cd" && \
        fail "Rename functions/variables to use argocd (reflecting the brand name ArgoCD)."

# 5. Check for uppercase common nouns in logs
echo "Checking for uppercase common nouns in logs."
grep -rE "echo \"(Username|Password|Infrastructure|Cluster):" . --exclude-dir={.git,.terraform} --exclude=bc-lint.sh && \
        fail "Use lowercase for common technical nouns in log messages (e.g., \"username:\")."

# 6. Check for trailing slashes in URIs within logs
echo "Checking for trailing slashes in URIs."
grep -rE "echo \".*(gs|s3|https?)://.*/\"" . --exclude-dir={.git,.terraform} --exclude=bc-lint.sh && \
        fail "Avoid unnecessary trailing slashes in URIs within log messages."

# 7. Check for spaces around assignment in Shell/Terraform
echo "Checking for spaces around '=' in Shell/Terraform."
find . -type f \( -name "*.sh" -o -name "*.tf" \) -not -path "*/.terraform/*" -not -name "bc-lint.sh" -not -name "harmonize-format.sh" | xargs grep -E "[^!<> \t] = [^=]" | grep -vE " == | != | <= | >= |if |while |\[" && \
        fail "Remove spaces around assignment '=' (use key=value, not key = value)."

# 8. Check for 'local var' pattern (The Brian Chan Rule)
# Consolidated: local var="${val}" (No subshell)
# Split: local var; var=$(cmd) (If subshell)
echo "Checking for 'local' variable declaration patterns."

# Fail if local var assignment uses a subshell on one line
find . -name "*.sh" -not -name "bc-lint.sh" | xargs grep -E "local [a-zA-Z0-9_]+=\$\(" && \
        fail "Split sub-shell assignments: local var; var=\$(cmd)."

# Fail if simple local var assignment is split across two lines
# (This is harder to catch with grep, but we can catch the 'local var;' part)
find . -name "*.sh" -not -name "bc-lint.sh" | xargs grep -E "local [a-zA-Z0-9_]+;" && \
        fail "Consolidate simple assignments: local var=\"\${val}\"."

if [ $EXIT_CODE -eq 0 ]; then
        echo "----------------------------------------"
        echo "SUCCESS: All pickiness checks passed!"
else
        echo "----------------------------------------"
        echo "FAILED: Some stylistic issues were found. Fix them to appease the CEO."
fi

exit $EXIT_CODE
