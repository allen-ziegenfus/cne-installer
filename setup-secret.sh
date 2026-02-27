#!/bin/bash
PROJECT_ID=$1
SECRET_NAME=$2

if [ -z "$PROJECT_ID" ] || [ -z "$SECRET_NAME" ]; then
    echo "Usage: ./setup-secret.sh <PROJECT_ID> <SECRET_NAME>"
    exit 1
fi

echo "Checking for existing secret: $SECRET_NAME..."

if gcloud secrets describe "$SECRET_NAME" --project="$PROJECT_ID" > /dev/null 2>&1; then
    echo "Secret '$SECRET_NAME' already exists."
    read -p "Do you want to update the value? (y/N): " UPDATE
    if [[ ! "$UPDATE" =~ ^[Yy]$ ]]; then
        echo "Exiting without changes."
        exit 0
    fi
else
    echo "Creating new secret: $SECRET_NAME..."
    gcloud secrets create "$SECRET_NAME" \
        --replication-policy="automatic" \
        --project="$PROJECT_ID"
fi

echo "------------------------------------"
echo "Enter the value for $SECRET_NAME"
echo "(It will not be displayed on screen)"
echo "------------------------------------"
read -s SECRET_VALUE

if [ -z "$SECRET_VALUE" ]; then
    echo "Error: Value cannot be empty."
    exit 1
fi

echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" --data-file=- --project="$PROJECT_ID"

echo "------------------------------------"
echo "✅ Secret stored successfully!"
echo "------------------------------------"
