terraform {
	required_providers {
		google={
			source="hashicorp/google"
			version=">= 5.0"
		}
		helm={
			source="hashicorp/helm"
			version=">= 2.0"
		}
		kubernetes={
			source="hashicorp/kubernetes"
			version=">= 2.0"
		}
	}
	required_version=">= 1.0"
}

data "google_client_config" "default" {}

data "google_container_cluster" "primary" {
	location=var.region
	name="${var.deployment_name}-gke"
	project=var.project_id
}

provider "helm" {
	kubernetes={
		cluster_ca_certificate=base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
		host="https://${data.google_container_cluster.primary.endpoint}"
		token=data.google_client_config.default.access_token
	}
}

provider "kubernetes" {
	cluster_ca_certificate=base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
	host="https://${data.google_container_cluster.primary.endpoint}"
	token=data.google_client_config.default.access_token
}
