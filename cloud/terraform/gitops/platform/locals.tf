locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = local.terraform_manager_name
    "environment"                  = "internal"
  }
  terraform_manager_name = "liferay-cloud-native-terraform"

   node_selector = {}

  node_affinity = var.spot ? {
    requiredDuringSchedulingIgnoredDuringExecution = {
      nodeSelectorTerms = [{
        matchExpressions = [{
          key      = "cloud.google.com/gke-spot"
          operator = "In"
          values   = ["true"]
        }]
      }]
    }
    preferredDuringSchedulingIgnoredDuringExecution = [{
      weight = 100
      preference = {
        matchExpressions = [{
          key      = "cloud.google.com/compute-class"
          operator = "In"
          values   = ["Scale-Out"]
        }]
      }
    }]
    } : {
    requiredDuringSchedulingIgnoredDuringExecution  = null
    preferredDuringSchedulingIgnoredDuringExecution = null
  }

  tolerations = var.spot ? [
    {
      key      = "cloud.google.com/gke-spot"
      operator = "Equal"
      value    = "true"
      effect   = "NoSchedule"
    }
  ] : []
}
