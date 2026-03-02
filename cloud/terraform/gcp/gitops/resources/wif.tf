# ---------------------------------------------------------------------------------------------------------------------
# GITHUB WORKLOAD IDENTITY FEDERATION
# ---------------------------------------------------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = var.github_workload_identity_pool_id
  display_name              = "GitHub Workload Identity Pool"
  description               = "Identity pool for GitHub Actions"
  project                   = var.project_id
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "Identity pool provider for GitHub Actions"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = length(local.allowed_github_repos) > 0 ? "assertion.repository in [${join(",", formatlist("'%s'", local.allowed_github_repos))}]" : null

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DIRECT IAM PERMISSIONS FOR WORKSPACE REPOSITORY
# ---------------------------------------------------------------------------------------------------------------------

resource "google_artifact_registry_repository_iam_member" "workspace_gar_writer" {
  count      = var.liferay_workspace_git_repo_url != "" ? 1 : 0
  project    = data.google_artifact_registry_repository.liferay_registry.project
  location   = data.google_artifact_registry_repository.liferay_registry.location
  repository = data.google_artifact_registry_repository.liferay_registry.name
  role       = "roles/artifactregistry.writer"
  member     = "principalSet://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.liferay_workspace_git_repo_url}"
}
