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

```sh
gcloud config set project <walkthrough-project-id/>
```

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
The script below will generate a unique bucket name, prompt you for your preferred region, and create the bucket with **versioning enabled**.

<walkthrough-editor-open-file filePath="./create_tfstate_bucket.sh">View creat_tfstate_bucket.sh</walkthrough-editor-open-file>

```sh
./create_tfstate_bucket.sh <walkthrough-project-id/>
```

> [!TIP]
> This script also sets your `TF_VAR` environment variables so Infrastructure Manager knows which region to use for the rest of the install.

## Create Service Accounts
To run the terraform scripts with Infrastructure Manager and Cloud Build we need to create a service account and permissions for the cloud build runner. 

### 1. Run the IAM Setup
The script below will generate a service account and allow Cloud Build to run with the configured permissions. 

<walkthrough-editor-open-file filePath="./setup-iam.sh">View setup-iam.sh</walkthrough-editor-open-file>

```sh
./setup-iam.sh <walkthrough-project-id/>
```