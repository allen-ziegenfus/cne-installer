#!/bin/bash
PROJECT_ID=$1

if [ -z "$PROJECT_ID" ]; then
    echo "Usage: ./setup-iam.sh <PROJECT_ID>"
    exit 1
fi

SA_NAME="infra-manager-runner"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "------------------------------------"
echo "Configuring IAM for Infrastructure Manager..."
echo "------------------------------------"

# 1. Check/Create the Service Account
if gcloud iam service-accounts describe "$SA_EMAIL" --project="$PROJECT_ID" > /dev/null 2>&1; then
    echo "Service Account $SA_EMAIL already exists. Skipping creation."
else
    echo "Creating Service Account $SA_NAME..."
    gcloud iam service-accounts create $SA_NAME \
        --display-name="Infrastructure Manager Runner" \
        --project="$PROJECT_ID"
fi

# 2. Grant the Service Account project editor/admin roles 
RESOURCES_ROLES=("roles/editor" "roles/owner" "roles/logging.logWriter" "roles/storage.objectViewer")

echo "Ensuring project-level IAM bindings..."
for ROLE in "${RESOURCES_ROLES[@]}"; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="serviceAccount:$SA_EMAIL" \
      --role="$ROLE" \
      --quiet > /dev/null
done

# 3. Get the Project Number
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")

# 4. Grant Infra Manager Service Agent permission to "act as" the Runner
echo "Configuring Infrastructure Manager Service Agent..."
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:service-${PROJECT_NUMBER}@gcp-sa-config.iam.gserviceaccount.com" \
    --role="roles/config.agent" \
    --quiet > /dev/null

CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

echo "Granting Cloud Build SA permissions to manage Infra Manager..."

# Grant Cloud Build the ability to create and manage deployments
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/config.admin" \
    --quiet > /dev/null

# Grant Cloud Build permission to "act as" the Runner Service Account
echo "Granting Cloud Build permission to act as the Runner..."
gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/iam.serviceAccountUser" \
    --project="$PROJECT_ID" \
    --quiet > /dev/null

echo "✅ IAM Configuration Complete."

