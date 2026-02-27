#!/bin/bash
PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./create_tfstate_bucket.sh <PROJECT_ID>"
    exit 1
fi

echo "Checking for existing Terraform state bucket..."

# Search for an existing bucket matching the naming convention
EXISTING_BUCKET=$(gcloud storage buckets list --project="$PROJECT_ID" --format="value(name)" --filter="name ~ ^tf-state-${PROJECT_ID}-" | head -n 1)

if [ -n "$EXISTING_BUCKET" ]; then
    echo "------------------------------------"
    echo "FOUND EXISTING BUCKET: $EXISTING_BUCKET"
    
    # Extract region of existing bucket and force to lowercase
    REGION=$(gcloud storage buckets describe "gs://$EXISTING_BUCKET" --format="value(location)" | tr '[:upper:]' '[:lower:]')
    echo "REGION DETECTED: $REGION"
    echo "------------------------------------"
    BUCKET_NAME="$EXISTING_BUCKET"
else
    echo "No existing bucket found. Creating a new one..."
    
    # Generate a unique suffix for the bucket name
    BUCKET_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
    BUCKET_NAME="tf-state-${PROJECT_ID}-${BUCKET_SUFFIX}"

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
fi

# Export variables for the current session
export TF_VAR_project_id="$PROJECT_ID"
export TF_VAR_region="$REGION"
export STATE_BUCKET="$BUCKET_NAME"

# Update terraform.tfvars
TFVARS_FILE="cloud/terraform/gcp/gke/terraform.tfvars"
if [ -f "$TFVARS_FILE" ]; then
    # Remove existing entries to avoid duplicates
    sed -i '/project_id/d' "$TFVARS_FILE"
    sed -i '/region/d' "$TFVARS_FILE"
    sed -i '/state_bucket/d' "$TFVARS_FILE"

    # Append new values
    cat <<EOF >> "$TFVARS_FILE"
project_id   = "$PROJECT_ID"
region       = "$REGION"
state_bucket = "$BUCKET_NAME"
EOF
    echo "Updated $TFVARS_FILE with automated settings."
fi