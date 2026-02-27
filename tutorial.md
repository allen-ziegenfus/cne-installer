# Liferay Cloud Native - GCP Installer

## Welcome
Welcome to the Liferay Cloud Native GCP Installer. This guided tutorial will walk you through the installation process.

To get started, click **Next**.


## Select GCP Project
Before running the installer, you need to select the Google Cloud project where you want to deploy Liferay.

Click the button below to select your project:

<walkthrough-project-setup billing="true"></walkthrough-project-setup>

Once selected, you can verify it in your terminal:

```sh
gcloud config get-value project
```

## Enable APIs
The installer requires several Google Cloud APIs to be enabled to automate the creation and management of your environment:

- **Cloud Build (`cloudbuild.googleapis.com`)**: Executes the deployment and build processes.
- **Infrastructure Manager (`config.googleapis.com`)**: Orchestrates the Terraform deployment as a managed service on GCP.
- **Compute Engine (`compute.googleapis.com`)**: Required for the VMs that will run as your GKE worker nodes.
- **Google Kubernetes Engine (`container.googleapis.com`)**: The core API for creating and managing your Kubernetes cluster.
- **Cloud Resource Manager (`cloudresourcemanager.googleapis.com`)**: Manages project-level metadata and IAM permissions.
- **Identity & Access Management (`iam.googleapis.com`)**: Required for managing service accounts and roles.
- **IAM Credentials (`iamcredentials.googleapis.com`)**: Enables generating short-lived credentials for Workload Identity.
- **Security Token Service (`sts.googleapis.com`)**: Supports Workload Identity Federation for secure service communication.
- **Cloud Storage (`storage-api.googleapis.com`)**: Stores Terraform state files and other application data.
- **Artifact Registry (`artifactregistry.googleapis.com`)**: A secure repository for your Docker images and Helm charts.
- **Cloud SQL Admin (`sqladmin.googleapis.com`)**: Required for creating and managing Cloud SQL database instances.
- **Secret Manager (`secretmanager.googleapis.com`)**: Securely stores sensitive data like passwords and API keys.
- **Service Networking (`servicenetworking.googleapis.com`)**: Configures private connectivity between your VPC and Google services.
- **Service Management & Control (`servicemanagement.googleapis.com`, `servicecontrol.googleapis.com`)**: Foundational services for managing API access and visibility.

Click the button below to enable these APIs for your project:

<walkthrough-enable-apis apis="cloudbuild.googleapis.com,config.googleapis.com,compute.googleapis.com,container.googleapis.com,cloudresourcemanager.googleapis.com,iam.googleapis.com,iamcredentials.googleapis.com,sts.googleapis.com,storage-api.googleapis.com,artifactregistry.googleapis.com,sqladmin.googleapis.com,secretmanager.googleapis.com,servicenetworking.googleapis.com,servicemanagement.googleapis.com,servicecontrol.googleapis.com">
</walkthrough-enable-apis>