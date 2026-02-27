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

## Configure Region
Choose the Google Cloud region where you want to deploy your infrastructure.

<walkthrough-editor-open-file filePath="./setup-region.sh">View setup-region.sh</walkthrough-editor-open-file>

```sh
source ./setup-region.sh <walkthrough-project-id/>
```

> [!IMPORTANT]
> We use `source` to ensure the region is saved as an environment variable in your current session. This script also updates your `terraform.tfvars` file automatically.

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

## Optional: Advanced Configuration
Before running the deployment, you can customize your environment by editing the Terraform variables file directly.

### Edit Variables
Click the button below to open the variables file in the editor:

<walkthrough-editor-open-file filePath="cloud/terraform/gcp/gke/terraform.tfvars">Open terraform.tfvars</walkthrough-editor-open-file>

### Common Settings
You can copy/paste these examples into the file:

*   **Authorized Networks:**
    `authorized_ipv4_cidr_block = "YOUR_IP/32"`
*   **Custom Domains:**
    `domains = ["example.com", "myportal.io"]`
*   **Cloudflare Integration:**
    ```hcl
    enable_cloudflare     = true
    cloudflare_account_id = "your-id"
    cloudflare_zone_id    = "your-zone"
    ```

> [!TIP]
> **Why edit the file?** Editing `terraform.tfvars` makes your settings "permanent" for the life of this project. Any settings you provide in the file will be used during the build. Essential settings (Project ID, Region) are automatically handled by the installer.

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
