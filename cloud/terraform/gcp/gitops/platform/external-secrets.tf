resource "helm_release" "external_secrets" {
  chart            = "external-secrets"
  create_namespace = true
  name             = "external-secrets"
  namespace        = var.external_secrets_namespace
  repository       = "https://charts.external-secrets.io"
  upgrade_install  = true
  values = [
    yamlencode(
      {
        certController = {
          nodeSelector = local.node_selector
          tolerations  = local.tolerations
          affinity     = { nodeAffinity = local.node_affinity }
          resources = {
            limits = {
              cpu    = "20m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }
        }
        installCRDs = true
        nodeSelector = local.node_selector
        tolerations  = local.tolerations
        affinity     = { nodeAffinity = local.node_affinity }
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
        webhook = {
          nodeSelector = local.node_selector
          tolerations  = local.tolerations
          resources = {
            limits = {
              cpu    = "20m"
              memory = "64Mi"
            }
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }
        }
    }),
  ]
  version = "1.0.0"
  wait    = true
}