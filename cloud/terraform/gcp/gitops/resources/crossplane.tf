# ---------------------------------------------------------
# 1. Cloud SQL (GCP SQL Admin)
# ---------------------------------------------------------
resource "google_service_account" "provider_gcp_sql_sa" {
  account_id   = "${var.deployment_name}-cp-sql"
  display_name = "Crossplane GCP SQL Service Account"
}

resource "google_project_iam_member" "sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "serviceAccount:${google_service_account.provider_gcp_sql_sa.email}"
}

resource "google_service_account_iam_member" "sql_wif_binding" {
  service_account_id = google_service_account.provider_gcp_sql_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}/provider-gcp-sql]"
}

# ---------------------------------------------------------
# 2. Compute Engine & Networking (GCP Compute Admin)
# ---------------------------------------------------------
resource "google_service_account" "provider_gcp_compute_sa" {
  account_id   = "${var.deployment_name}-cp-compute"
  display_name = "Crossplane GCP Compute Service Account"
}

resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.provider_gcp_compute_sa.email}"
}

resource "google_service_account_iam_member" "compute_wif_binding" {
  service_account_id = google_service_account.provider_gcp_compute_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}/provider-gcp-compute]"
}

# ---------------------------------------------------------
# 3. Storage (GCP Storage Admin)
# ---------------------------------------------------------
resource "google_service_account" "provider_gcp_storage_sa" {
  account_id   = "${var.deployment_name}-cp-storage"
  display_name = "Crossplane GCP Storage Service Account"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.provider_gcp_storage_sa.email}"
}

resource "google_service_account_iam_member" "storage_wif_binding" {
  service_account_id = google_service_account.provider_gcp_storage_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}/provider-gcp-storage]"
}


# ---------------------------------------------------------
# 4. IAM 
# ---------------------------------------------------------

resource "google_service_account" "provider_gcp_cloudplatform_sa" {
  account_id   = "${var.deployment_name}-cp-iam"
  display_name = "Crossplane GCP Cloud Platform Service Account"
}

# 1. Define the roles needed by the Cloud Platform provider
locals {
  provider_roles = [
    "roles/iam.serviceAccountAdmin", # To manage GSAs
    "roles/iam.securityAdmin",       # To manage project IAM policy
  ]

  # Managed Service Accounts that this provider needs to impersonate
  managed_sas = {
    sql           = google_service_account.provider_gcp_sql_sa.name
    compute       = google_service_account.provider_gcp_compute_sa.name
    storage       = google_service_account.provider_gcp_storage_sa.name
    cloudplatform = google_service_account.provider_gcp_cloudplatform_sa.name
  }
}

# Bind the admin roles to the Provider's GSA using for_each
resource "google_project_iam_member" "provider_iam_roles" {
  # checkov:skip=CKV_GCP_49:This Service Account is the designated IAM controller for the Crossplane platform and requires project-level admin permissions to manage GSAs and IAM policies.
  for_each = toset(local.provider_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.provider_gcp_cloudplatform_sa.email}"
}

# Grant Service Account User role at the resource level instead of project level
# to satisfy CKV_GCP_41 and CKV_GCP_49.
resource "google_service_account_iam_member" "provider_sa_user" {
  for_each = local.managed_sas

  service_account_id = each.value
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.provider_gcp_cloudplatform_sa.email}"
}
resource "google_service_account_iam_member" "cloudplatform_wif_binding" {
  service_account_id = google_service_account.provider_gcp_cloudplatform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}/provider-gcp-cloudplatform]"
}


# ---------------------------------------------------------
# 5. Crossplane Functions (Standard)
# ---------------------------------------------------------
resource "kubernetes_manifest" "function_auto_ready" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-auto-ready"
    }
    spec = {
      package = "xpkg.upbound.io/upbound/function-auto-ready:v0.6.0"
    }
  }
}

resource "kubernetes_manifest" "function_go_templating" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-go-templating"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.11.3"
    }
  }
}

resource "kubernetes_manifest" "function_environment_configs" {
  manifest = {
    apiVersion = "pkg.crossplane.io/v1beta1"
    kind       = "Function"
    metadata = {
      name = "function-environment-configs"
    }
    spec = {
      package = "xpkg.upbound.io/crossplane-contrib/function-environment-configs:v0.6.0"
    }
  }
  provider = kubernetes
}