module "netbird" {
	count=var.enable_netbird ? 1 : 0
	deployment_name=var.deployment_name
	namespace="infra"
	netbird_proxy_token=data.google_secret_manager_secret_version.netbird_proxy_token[0].secret_data
	source="./modules/netbird"
}
