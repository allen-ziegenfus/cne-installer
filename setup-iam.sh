#!/bin/bash
PROJECT_ID=$1
SA_NAME="infra-manager-runner"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "------------------------------------"
echo "Configuring IAM for Infrastructure Manager..."
echo "------------------------------------"

# 1. Create the Service Account
gcloud iam service-accounts create $SA_NAME \
    --display-name="Infrastructure Manager Runner" \
    --project="$PROJECT_ID"

# 2. Grant the Service Account project editor/admin roles 
# Adjust these roles if your Terraform needs more specific (or less) access
RESOURCES_ROLES=("roles/editor" "roles/owner")

for ROLE in "${RESOURCES_ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:$SA_EMAIL" \
      --role="$ROLE" \
      --quiet
done

# 3. Get the Project Number
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

# 4. Grant Infra Manager Service Agent permission to "act as" the Runner
# This binding is required for the service to function
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/config.agent" \
    --quiet

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "Granting Cloud Build SA permissions to manage Infra Manager..."

# Grant Cloud Build the ability to create and manage deployments
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/config.admin" \
    --quiet

# Grant Cloud Build permission to "act as" the Runner Service Account
gcloud iam service-accounts add-iam-policy-binding "infra-manager-runner@${PROJECT_ID}.iam.gserviceaccount.com" \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/iam.serviceAccountUser" \
    --project="$PROJECT_ID" \
    --quiet

echo "✅ IAM Configuration Complete."
