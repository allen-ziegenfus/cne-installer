resource "helm_release" "argocd" {
  chart            = "argo-cd"
  create_namespace = false
  depends_on = [
    kubernetes_namespace.argocd
  ]
  name            = "argocd"
  namespace       = var.argocd_namespace
  repository      = "https://argoproj.github.io/argo-helm"
  upgrade_install = true
  values = [
    yamlencode(
      {
        applicationSet = {
          resources = {
            limits = {
              cpu    = "800m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }

        global = {
          domain = var.argocd_domain != "" ? var.argocd_domain : null
          logging = {
            format = "json"
            level  = "info"
          }
          nodeSelector = local.node_selector
          tolerations  = local.tolerations
          affinity     = { nodeAffinity = local.node_affinity }
        }

        controller = {
          resources = {
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
        }

        repoServer = {
          resources = {
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
        }

        server = {
          extraArgs = ["--insecure"]
          livenessProbe = {
            initialDelaySeconds = 90
            timeoutSeconds      = 5
          }
          readinessProbe = {
            initialDelaySeconds = 60
            timeoutSeconds      = 5
          }
          resources = {
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
          }
          service = {
            type = "ClusterIP"
          }
        }

        redis = {
          resources = {
            limits = {
              cpu    = "200m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }
        }

        installCRDs = true

        configs = {
          params = {
            "server.insecure" = true
          }
          cm = {
            "application.resourceTrackingMethod" = "annotation"
            "resource.exclusions" = yamlencode(
              [
                {
                  apiGroups = ["*"]
                  kinds     = ["ProviderConfigUsage"]
                },
                {
                  apiGroups = ["apiextensions.crossplane.io"]
                  kinds     = ["ManagedResourceDefinition"]
                },
            ])
            "resource.customizations.health.gcp.liferay.com_LiferayInfrastructure" = templatefile(
              "${path.module}/liferayinfrastructure-health-check.lua",
              {}
            )
            "application.allowedNodeLabels" = "cloud.google.com/gke-spot,cloud.google.com/gke-compute-class,node.kubernetes.io/instance-type,topology.kubernetes.io/zone"
          }
          rbac = {
            create = false
          }
          secret = {
            extra = {
              "webhook.github.secret" = var.argocd_github_webhook_config.enable_webhook ? data.google_secret_manager_secret_version.github_webhook[0].secret_data : ""
              "server.secretkey"      = random_password.argocd_server_secretkey.result
            }
          }
        }
    }),
    var.argocd_auth_config.enable_sso ? module.argocd_auth_resources[0].auth_helm_values : "{}",
    var.enable_argocd_ui_tools ? module.argocd-ui-tools[0].argocd_ui_tools_helm_values : "{}"
  ]
  version = "9.4.4"
  wait    = true
}

data "google_secret_manager_secret_version" "github_webhook" {
  count  = var.argocd_github_webhook_config.enable_webhook ? 1 : 0
  secret = var.argocd_github_webhook_config.webhook_secret_name
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    labels = local.common_labels
    name   = var.argocd_namespace
  }
}
resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

resource "kubernetes_manifest" "argocd_http_route" {
  count = var.argocd_domain != "" ? 1 : 0
  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "HTTPRoute"
    "metadata" = {
      "name"      = "argocd-route"
      "namespace" = var.argocd_namespace
    }
    "spec" = {
      "parentRefs" = [
        {
          "name"      = "shared-gateway"
          "namespace" = "infra"
        }
      ]
      "hostnames" = [var.argocd_domain]
      "rules" = [
        {
          "backendRefs" = [
            {
              "name" = "argocd-server"
              "port" = 80
            }
          ]
        }
      ]
    }
  }
}

module "argocd_auth_resources" {
  count  = var.argocd_auth_config.enable_sso ? 1 : 0
  source = "./modules/argocd-auth-resources"

  argocd_auth_config = var.argocd_auth_config
}

module "argocd-ui-tools" {
  count  = var.enable_argocd_ui_tools ? 1 : 0
  source = "./modules/argocd-ui-tools"
}
