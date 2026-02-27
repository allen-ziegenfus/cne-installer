output "cluster_name" {
  value = module.gke.name
}

output "endpoint" {
  value     = module.gke.endpoint
  sensitive = true
}

output "liferay_gsa_email" {
  description = "The Google Service Account email for Workload Identity"
  value       = google_service_account.liferay_sa.email
}

output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "ca_certificate" {
  value     = module.gke.ca_certificate
  sensitive = true
}