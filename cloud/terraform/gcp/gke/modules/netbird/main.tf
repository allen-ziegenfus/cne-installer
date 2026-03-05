resource "kubernetes_deployment_v1" "netbird_proxy" {
	metadata {
		labels={
			app="netbird-proxy",
		}
		name="netbird-reverse-proxy"
		namespace=var.namespace
	}
	spec {
		replicas=1
		selector {
			match_labels={
				app="netbird-proxy",
			}
		}
		template {
			metadata {
				labels={
					app="netbird-proxy",
				}
			}
			spec {
				container {
					env {
						name="NETBIRD_PROXY_TOKEN"
						value=var.netbird_proxy_token
					}
					image="netbirdio/reverse-proxy:latest"
					name="proxy"
					resources {
						limits={
							cpu="500m"
							memory="512Mi",
						}
						requests={
							cpu="100m"
							memory="128Mi",
						}
					}
				}
			}
		}
	}
}
