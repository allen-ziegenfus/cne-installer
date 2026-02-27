# Grant the Liferay GSA access to the GCS Bucket
# This allows the GCS FUSE CSI driver (running as the pod) to mount the bucket
resource "google_project_iam_member" "liferay_gcs_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin" # Or roles/storage.objectViewer for read-only
  member  = "serviceAccount:${google_service_account.liferay_sa.email}"
}

# Optional: GCR/GAR Access (Equivalent to ECR IAM policy)
# If using Google Artifact Registry, the node pool SA usually has read access by default.
# If explicit access is needed for the Workload Identity:
resource "google_project_iam_member" "liferay_gar_access" {
  count   = length(var.ecr_repositories) > 0 ? 1 : 0
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.liferay_sa.email}"
}