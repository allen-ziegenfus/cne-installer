variable "deployment_name" {
	description="Deployment name, used for GKE cluster identification"
	type=string
}

variable "kyverno_namespace" {
	default="kyverno"
	type=string
}

variable "project_id" {
	description="The Google Cloud Project ID"
	type=string
}

variable "region" {
	default="us-central1"
	description="The GCP region"
	type=string
}

variable "spot" {
	default=true
	description="Enable spot node policy"
	type=bool
}
