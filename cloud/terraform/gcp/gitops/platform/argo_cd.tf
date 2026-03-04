resource "helm_release" "argo_cd" {
	chart="argo-cd"
	create_namespace=false
	depends_on=[
		kubernetes_namespace.argo_cd
	]
	name="argo-cd"
	namespace=var.argo_cd_namespace
	repository="https://argoproj.github.io/argo-helm"
	upgrade_install=true
	values=[
		yamlencode(
			{
				applicationSet={
					resources={
						limits={
							cpu="800m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
				}

				configs={
					cm={
						"application.allowedNodeLabels"="cloud.google.com/gke-spot,cloud.google.com/gke-compute-class,node.kubernetes.io/instance-type,topology.kubernetes.io/zone"
						"application.resourceTrackingMethod"="annotation"
						"resource.customizations.health.gcp.liferay.com_LiferayInfrastructure"=templatefile(
							"${path.module}/liferayinfrastructure-health-check.lua",
							{}
						)
						"resource.exclusions"=yamlencode(
							[
								{
									apiGroups=["*"]
									kinds=["ProviderConfigUsage"]
								},
								{
									apiGroups=["apiextensions.crossplane.io"]
									kinds=["ManagedResourceDefinition"]
								},
						])
					}
					params={
						"server.insecure"=true
					}
					rbac={
						create=false
					}
					secret={
						extra={
							"server.secretkey"=random_password.argo_cd_server_secretkey.result
							"webhook.github.secret"=var.argo_cd_github_webhook_config.enable_webhook ? data.google_secret_manager_secret_version.github_webhook[0].secret_data : ""
						}
					}
				}

				controller={
					resources={
						limits={
							cpu="1000m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
				}

				global={
					domain=var.argo_cd_domain != "" ? var.argo_cd_domain : null
					logging={
						format="json"
						level="info"
					}
				}

				installCRDs=true

				redis={
					resources={
						limits={
							cpu="200m"
							memory="512Mi"
						}
						requests={
							cpu="100m"
							memory="256Mi"
						}
					}
				}

				repoServer={
					resources={
						limits={
							cpu="1000m"
							memory="1Gi"
						}
						requests={
							cpu="250m"
							memory="512Mi"
						}
					}
				}

				server={
					extraArgs=["--insecure"]
					livenessProbe={
						initialDelaySeconds=90
						timeoutSeconds=5
					}
					readinessProbe={
						initialDelaySeconds=60
						timeoutSeconds=5
					}
					resources={
						limits={
							cpu="1000m"
							memory="2Gi"
						}
						requests={
							cpu="500m"
							memory="1Gi"
						}
					}
					service={
						type="ClusterIP"
					}
				}
		}),
		var.argo_cd_auth_config.enable_sso ? module.argo_cd_auth_resources[0].auth_helm_values : "{}",
		var.enable_argo_cd_ui_tools ? module.argo_cd_ui_tools[0].argo_cd_ui_tools_helm_values : "{}"
	]
	version="9.4.4"
	wait=true
}

data "google_secret_manager_secret_version" "github_webhook" {
	count=var.argo_cd_github_webhook_config.enable_webhook ? 1 : 0
	secret=var.argo_cd_github_webhook_config.webhook_secret_name
}

resource "kubernetes_namespace" "argo_cd" {
	metadata {
		labels=local.common_labels
		name=var.argo_cd_namespace
	}
}

resource "random_password" "argo_cd_server_secretkey" {
	length=32
	special=false
}

resource "kubernetes_manifest" "argo_cd_http_route" {
	count=var.argo_cd_domain != "" ? 1 : 0
	manifest={
		"apiVersion"="gateway.networking.k8s.io/v1"
		"kind"="HTTPRoute"
		"metadata"={
			"name"="argo-cd-route"
			"namespace"=var.argo_cd_namespace
		}
		"spec"={
			"hostnames"=[var.argo_cd_domain]
			"parentRefs"=[
				{
					"name"="shared-gateway"
					"namespace"="infra"
				}
			]
			"rules"=[
				{
					"backendRefs"=[
						{
							"name"="argo-cd-server"
							"port"=80
						}
					]
				}
			]
		}
	}
}

module "argo_cd_auth_resources" {
	argo_cd_auth_config=var.argo_cd_auth_config
	count=var.argo_cd_auth_config.enable_sso ? 1 : 0
	source="./modules/argo_cd_auth_resources"
}

module "argo_cd_ui_tools" {
	count=var.enable_argo_cd_ui_tools ? 1 : 0
	source="./modules/argo_cd_ui_tools"
}
