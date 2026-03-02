# ---------------------------------------------------------
# 1. Direct IAM Bindings for Crossplane Kubernetes Service Accounts
# ---------------------------------------------------------
# We grant permissions directly to the KSA principals using the 
# Direct Workload Identity principal format.
# ---------------------------------------------------------

locals {
  # The principal format for direct KSA binding
  ksa_principal_base = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.crossplane_namespace}/sa"
  
  # List of KSAs we want to grant permissions to
  provider_ksas = {
    sql           = { role = "roles/cloudsql.admin", ksa = "provider-gcp-sql" }
    compute       = { role = "roles/compute.admin",  ksa = "provider-gcp-compute" }
    storage       = { role = "roles/storage.admin",  ksa = "provider-gcp-storage" }
    cloudplatform = { role = "roles/iam.serviceAccountAdmin", ksa = "provider-gcp-cloudplatform" }
    projectiam    = { role = "roles/resourcemanager.projectIamAdmin", ksa = "provider-gcp-cloudplatform" }
    security      = { role = "roles/iam.securityAdmin", ksa = "provider-gcp-cloudplatform" }
  }
}

resource "google_project_iam_member" "provider_direct_iam" {
  for_each = local.provider_ksas

  project = var.project_id
  role    = each.value.role
  member  = "${local.ksa_principal_base}/${each.value.ksa}"
}

# ---------------------------------------------------------
# 2. Crossplane Functions (Standard)
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
