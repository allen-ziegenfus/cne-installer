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

> [!NOTE]
> **Cloudflare Integration:** By default, Cloudflare Zero Trust Tunnel is **disabled**. If you wish to enable it, you must set `enable_cloudflare = true` and provide your `cloudflare_account_id` and `cloudflare_zone_id` in your Terraform variables.

> [!TIP]
> **Securing Kubernetes Access:** By default, the GKE API is accessible to any authenticated user. To restrict access to only your specific IP address, set the `authorized_ipv4_cidr_block` variable to your public IP (e.g., `1.2.3.4/32`).

> [!TIP]
> **Custom Domains:** The `domains` variable is **optional**. If you don't provide any domains, the installer will set up the infrastructure without custom routing, and you can add domains later.

### 2. Run the Creation Script

The script below will generate a unique bucket name, prompt you for your preferred region, and create the bucket with **versioning enabled**.

<walkthrough-editor-open-file filePath="./create_tfstate_bucket.sh">View create_tfstate_bucket.sh</walkthrough-editor-open-file>

```sh
source ./create_tfstate_bucket.sh <walkthrough-project-id/>
```

> [!IMPORTANT]
> We use `source` to ensure the bucket name and region are saved as environment variables in your current session for the next steps.
> You can verify the bucket in the [Cloud Storage Browser](https://console.cloud.google.com/storage/browser?project=<walkthrough-project-id/>).

## Create Service Accounts
To run the terraform scripts with Infrastructure Manager and Cloud Build we need to create a service account and permissions for the cloud build runner. 

### 1. Run the IAM Setup
The script below will generate a service account and allow Cloud Build to run with the configured permissions. 

<walkthrough-editor-open-file filePath="./setup-iam.sh">View setup-iam.sh</walkthrough-editor-open-file>

```sh
./setup-iam.sh <walkthrough-project-id/>
```

> [!TIP]
> You can verify the created service account and its permissions in the [IAM Service Accounts Console](https://console.cloud.google.com/iam-admin/serviceaccounts?project=<walkthrough-project-id/>).

## Kick off the build
Now we can invoke Cloud Build and Infrastructure Manager to actually run the build!

### 1. Run the build
The script below will actually invoke the terraform build

<walkthrough-editor-open-file filePath="./submit_build.sh">View submit_build.sh</walkthrough-editor-open-file>
<walkthrough-editor-open-file filePath="./cloudbuild.yaml">View cloudbuild.yaml</walkthrough-editor-open-file>


```sh
./submit_build.sh <walkthrough-project-id/>
```

### 2. Monitor Progress
Once the build is submitted, you can track its progress and view logs in the Google Cloud Console.

*   [View Build History in Console](https://console.cloud.google.com/cloud-build/builds?project=<walkthrough-project-id/>)
*   [View Infrastructure Manager Deployments](https://console.cloud.google.com/infra-manager/deployments?project=<walkthrough-project-id/>)

## Verify the Cluster
After the Infrastructure Manager deployment finishes, your GKE cluster will be ready.

### View GKE Cluster
You can inspect the cluster nodes, workloads, and services in the Kubernetes Engine dashboard.

*   [View GKE Clusters](https://console.cloud.google.com/kubernetes/list/overview?project=<walkthrough-project-id/>)

Congratulations! You have successfully initiated the Liferay Cloud Native deployment on GCP.