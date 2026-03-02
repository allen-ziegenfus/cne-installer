# Optional: GCR/GAR Access (Equivalent to ECR IAM policy)
# If using Google Artifact Registry, the node pool SA usually has read access by default.
# If explicit access is needed for the Workload Identity:
resource "google_project_iam_member" "liferay_gar_access" {
  count   = length(var.ecr_repositories) > 0 ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.liferay_sa.email}"
}