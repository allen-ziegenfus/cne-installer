#!/bin/bash
PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./submit_build.sh <PROJECT_ID>"
    exit 1
fi

gcloud config set project "$PROJECT_ID"

# Auto-detect Region if not set
if [ -z "$TF_VAR_region" ]; then
    echo "Attempting to detect region from gcloud config..."
    TF_VAR_region=$(gcloud config get-value compute/region 2>/dev/null)
    if [ -z "$TF_VAR_region" ] || [ "$TF_VAR_region" == "(unset)" ]; then
        echo "Region not set. Defaulting to us-central1."
        TF_VAR_region="us-central1"
    fi
fi

REPO_URL=$(git config --get remote.origin.url)

echo "------------------------------------"
echo "Submitting Build for Project: $PROJECT_ID"
echo "Region: $TF_VAR_region"
echo "------------------------------------"

gcloud beta builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region"
