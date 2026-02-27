#!/bin/bash
PROJECT_ID=$1

# Generate a unique suffix for the bucket name
BUCKET_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
export BUCKET_NAME="tf-state-${PROJECT_ID}-${BUCKET_SUFFIX}"

# Ask the user for the region
read -p "Enter GCP Region (e.g., us-central1): " REGION

# Create the bucket using the modern gcloud storage command
gcloud storage buckets create "gs://$BUCKET_NAME" \
    --project="$PROJECT_ID" \
    --location="$REGION" \
    --uniform-bucket-level-access

# Enable versioning for state recovery
gcloud storage buckets update "gs://$BUCKET_NAME" --versioning

echo "------------------------------------"
echo "BUCKET CREATED: $BUCKET_NAME"
echo "REGION SET TO: $REGION"
echo "------------------------------------"

# Export variables for the current session to be used by Terraform/Infra Manager
export TF_VAR_project_id="$PROJECT_ID"
export TF_VAR_region="$REGION"
export STATE_BUCKET="$BUCKET_NAME"