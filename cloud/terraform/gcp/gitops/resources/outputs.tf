output "github_workload_identity_pool_id" {
  value       = google_iam_workload_identity_pool.github.workload_identity_pool_id
  description = "The ID of the GitHub Workload Identity Pool"
}

output "github_workload_identity_pool_name" {
  value       = google_iam_workload_identity_pool.github.name
  description = "The full name of the GitHub Workload Identity Pool"
}

output "github_workload_identity_provider_name" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "The full name of the GitHub Workload Identity Provider"
}
