#!/bin/bash
PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./submit_build.sh <PROJECT_ID>"
    exit 1
fi

gcloud config set project "$PROJECT_ID"

# Auto-detect Region if not set
if [ -z "$TF_VAR_region" ]; then
    echo "Attempting to detect region..."
    EXISTING_BUCKET=$(gcloud storage buckets list --project="$PROJECT_ID" --format="value(name)" --filter="name ~ ^tf-state-${PROJECT_ID}-" | head -n 1)
    if [ -n "$EXISTING_BUCKET" ]; then
        TF_VAR_region=$(gcloud storage buckets describe "gs://$EXISTING_BUCKET" --format="value(location)" | tr '[:upper:]' '[:lower:]')
        STATE_BUCKET="$EXISTING_BUCKET"
        echo "Detected Region: $TF_VAR_region"
        echo "Detected Bucket: $STATE_BUCKET"
    else
        echo "Error: Could not detect region or state bucket. Please run source ./create_tfstate_bucket.sh first."
        exit 1
    fi
fi

# Ensure STATE_BUCKET is set
if [ -z "$STATE_BUCKET" ]; then
    STATE_BUCKET=$(gcloud storage buckets list --project="$PROJECT_ID" --format="value(name)" --filter="name ~ ^tf-state-${PROJECT_ID}-" | head -n 1)
fi

REPO_URL=$(git config --get remote.origin.url)

echo "------------------------------------"
echo "Submitting Build for Project: $PROJECT_ID"
echo "Region: $TF_VAR_region"
echo "Bucket: $STATE_BUCKET"
echo "Repo:   $REPO_URL"
echo "------------------------------------"

gcloud beta builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region",_REPO_URL="$REPO_URL",_STATE_BUCKET="$STATE_BUCKET"
