# Liferay Cloud Native - GCP Installer

## Welcome
Welcome to the Liferay Cloud Native GCP Installer. This guided tutorial will walk you through the installation process.

### 💡 Pro-Tips for Navigation
* **Don't Close This Sidebar:** If you need to open a link to the Console, **right-click and "Open in New Tab"** to keep this guide visible.
* **The "Resume" Icon:** If this panel disappears, look for the **Learn** (graduation cap) icon in the top-right header to bring it back.

To get started, click **Next**.

## Select GCP Project
Before running the installer, you need to select the Google Cloud project where you want to deploy Liferay.

<walkthrough-project-setup billing="true" required="true"></walkthrough-project-setup>

Once selected, click the button below to sync your terminal environment:

<walkthrough-editor-button
  terminalCommand="gcloud config set project {{project-id}}">
  Confirm Project Selection
</walkthrough-editor-button>

## Enable APIs
The installer requires several Google Cloud APIs to be enabled to automate the creation and management of your environment. 

> [!NOTE]
> This process can take 1-2 minutes. The "Infrastructure Manager" and "Cloud Build" APIs are essential for the next steps.

<walkthrough-enable-apis apis="cloudbuild.googleapis.com,config.googleapis.com,compute.googleapis.com,container.googleapis.com,cloudresourcemanager.googleapis.com,iam.googleapis.com,iamcredentials.googleapis.com,sts.googleapis.com,storage-api.googleapis.com,artifactregistry.googleapis.com,sqladmin.googleapis.com,secretmanager.googleapis.com,servicenetworking.googleapis.com,servicemanagement.googleapis.com,servicecontrol.googleapis.com">
</walkthrough-enable-apis>

## Create Terraform State Bucket
Infrastructure Manager needs a place to store the Terraform "state" (the record of what has been built). We will create a secure, versioned Cloud Storage bucket for this.

### 1. Choose a Region
Common regions include `us-central1`, `europe-west1`, or `asia-east1`.

### 2. Run the Creation Script
The button below will generate a unique bucket name, prompt you for your preferred region, and create the bucket with **versioning enabled**.

<walkthrough-cloud-shell-snippet
  terminalCommand="export BUCKET_NAME=tf-state-{{project-id}}-$(cat /dev/urandom | tr -dc 'a-z0-4' | fold -w 6 | head -n 1); 
           read -p 'Enter GCP Region (e.g. us-central1): ' REGION;
           gsutil mb -l $REGION gs://$BUCKET_NAME;
           gsutil versioning set on gs://$BUCKET_NAME;
           echo '------------------------------------';
           echo 'BUCKET CREATED: '$BUCKET_NAME;
           echo 'REGION SET TO: '$REGION;
           echo '------------------------------------';
           export TF_VAR_project_id={{project-id}};
           export TF_VAR_region=$REGION">
</walkthrough-cloud-shell-snippet>

> [!TIP]
> This script also sets your `TF_VAR` environment variables so Infrastructure Manager knows which region to use for the rest of the install.