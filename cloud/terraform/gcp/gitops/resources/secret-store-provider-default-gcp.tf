# Generic GSA for any secret access in this project
resource "google_service_account" "cluster_secrets_accessor" {
  count        = local.git_repo_secret_store_provider_default_enabled ? 1 : 0
  account_id   = "${var.deployment_name}-secrets" # Generic name
  display_name = "GSA for Cluster-wide Secret Access"
}

# Permission for the generic GSA to read secrets
resource "google_project_iam_member" "secrets_accessor_permissions" {
  count   = local.git_repo_secret_store_provider_default_enabled ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cluster_secrets_accessor[0].email}"
}

# Bind the ESO Operator identity to the generic GSA
resource "google_service_account_iam_member" "wif_binding" {
  count              = local.git_repo_secret_store_provider_default_enabled ? 1 : 0
  service_account_id = google_service_account.cluster_secrets_accessor[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.external_secrets_namespace}/external-secrets]"
}

# Update the annotation to point to the new generic email
resource "kubernetes_annotations" "eso_sa_wif_link" {
  count       = local.git_repo_secret_store_provider_default_enabled ? 1 : 0
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "external-secrets"
    namespace = var.external_secrets_namespace
  }
  annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.cluster_secrets_accessor[0].email
  }
}