resource "helm_release" "gateway_crds" {
	chart="${path.module}/helm/gateway-crds"
	create_namespace=true
	name="gateway-crds"
	namespace="infra"
	version="1.0.1"
}
resource "helm_release" "gateway_infra" {
	chart="${path.module}/helm/gateway-infra"
	create_namespace=true
	depends_on=[
		helm_release.gateway_crds,
	]
	name="gateway-infra"
	namespace="infra"
	recreate_pods=true
	set=[
		{
			name="envoy-gateway.enabled"
			value=var.networking_mode == "gateway" ? "true" : "false"
		},
	]
	skip_crds=true
	values=[
		yamlencode({
			domains=var.domains,
		}),
	]
	version="1.0.3"
}
