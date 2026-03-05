data "google_client_config" "default" {}
data "google_secret_manager_secret_version" "cloudflare_api_token" {
	count=var.enable_cloudflare ? 1 : 0
	project=var.project_id
	secret="cloudflare-api-token"
}
data "google_secret_manager_secret_version" "netbird_proxy_token" {
	count=var.enable_netbird ? 1 : 0
	project=var.project_id
	secret="netbird-proxy-token"
}
provider "cloudflare" {
	api_token=var.enable_cloudflare ? data.google_secret_manager_secret_version.cloudflare_api_token[0].secret_data : "0000000000000000000000000000000000000000"
}
provider "google" {
	default_labels={
		deployment_name=var.deployment_name,
	}
	project=var.project_id
	region=var.region
}
provider "helm" {
	kubernetes={
		cluster_ca_certificate=base64decode(module.gke.ca_certificate)
		host="https://${module.gke.endpoint}"
		token=data.google_client_config.default.access_token,
	}
}
provider "kubernetes" {
	cluster_ca_certificate=base64decode(module.gke.ca_certificate)
	host="https://${module.gke.endpoint}"
	token=data.google_client_config.default.access_token
}
terraform {
	required_providers {
		cloudflare={
			source="cloudflare/cloudflare"
			version="~> 5.0"
		}
		google={
			source="hashicorp/google"
			version="~> 7.0"
		}
		helm={
			source="hashicorp/helm"
			version="~> 3.1"
		}
		kubernetes={
			source="hashicorp/kubernetes"
			version="~> 2.24"
		}
		random={
			source="hashicorp/random"
			version="~> 3.0"
		}
		time={
			source="hashicorp/time"
			version="~> 0.9"
		}
	}
	required_version=">= 1.5.0"
}
