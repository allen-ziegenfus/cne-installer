# 1. Fetch current Google Project metadata (Project ID, Project Number) 
data "google_project" "project" {}

# 2. Get the current GCP client configuration (used for OAuth2 tokens) 
data "google_client_config" "default" {}

# 3. (Optional) Fetch VPC details if you need to reference them for Crossplane 
# This assumes your VPC name matches your deployment name
data "google_compute_network" "vpc" {
  name = "${var.deployment_name}-vpc"
}

# 4. (Optional) Fetch subnets if needed for specific platform services 
data "google_compute_subnetwork" "private_subnet" {
  name   = "${var.deployment_name}-subnet"
  region = var.region
}