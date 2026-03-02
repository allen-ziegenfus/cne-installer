# ---------------------------------------------------------
# 1. Direct IAM Bindings for Crossplane Kubernetes Service Accounts
# ---------------------------------------------------------
# We grant permissions directly to the KSA principals in the format:
# serviceAccount:<PROJECT_ID>.svc.id.goog[<NAMESPACE>/<KSA_NAME>]
# ---------------------------------------------------------

locals {
  ksa_principal_prefix = "serviceAccount:${var.project_id}.svc.id.goog[${var.crossplane_namespace}"
  
  provider_ksa_bindings = {
    sql           = { role = "roles/cloudsql.admin", ksa = "provider-gcp-sql" }
    compute       = { role = "roles/compute.admin",  ksa = "provider-gcp-compute" }
    storage       = { role = "roles/storage.admin",  ksa = "provider-gcp-storage" }
    cloudplatform = { role = "roles/iam.serviceAccountAdmin", ksa = "provider-gcp-cloudplatform" }
    security      = { role = "roles/iam.securityAdmin", ksa = "provider-gcp-cloudplatform" }
  }
}

resource "google_project_iam_member" "provider_direct_iam" {
  for_each = local.provider_ksa_bindings

  project = var.project_id
  role    = each.value.role
  member  = "${local.ksa_principal_prefix}/${each.value.ksa}]"
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