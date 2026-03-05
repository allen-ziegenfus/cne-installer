data "cloudflare_zero_trust_tunnel_cloudflared_token" "gke_tunnel_token" {
	account_id=var.cloudflare_account_id
	tunnel_id=cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id
}
resource "cloudflare_dns_record" "root_dns" {
	content="${cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id}.cfargotunnel.com"
	for_each=toset(var.domains)
	name=each.value
	proxied=true
	ttl=1
	type="CNAME"
	zone_id=var.cloudflare_zone_id
}
resource "cloudflare_dns_record" "wildcard_dns" {
	content="${cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id}.cfargotunnel.com"
	for_each=toset(var.domains)
	name="*.${each.value}"
	proxied=true
	ttl=1
	type="CNAME"
	zone_id=var.cloudflare_zone_id
}
resource "cloudflare_zero_trust_tunnel_cloudflared" "gke_tunnel" {
	account_id=var.cloudflare_account_id
	config_src="cloudflare"
	name="${var.deployment_name}-tunnel"
	tunnel_secret=random_id.tunnel_secret.b64_std
}
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "gke_tunnel_config" {
	account_id=var.cloudflare_account_id
	config={
		ingress=concat(
			[for d in var.domains : {
				hostname=d
				service="http://envoy-internal-proxy.infra.svc.cluster.local:80",
			}],
			[for d in var.domains : {
				hostname="*.${d}"
				service="http://envoy-internal-proxy.infra.svc.cluster.local:80",
			}],
			[{
				service="http_status:404",
			}],
		),
	}
	tunnel_id=cloudflare_zero_trust_tunnel_cloudflared.gke_tunnel.id
}
resource "helm_release" "cloudflare_tunnel" {
	chart="cloudflare-tunnel-remote"
	create_namespace=true
	name="cloudflare-tunnel-remote"
	namespace="infra"
	repository="https://cloudflare.github.io/helm-charts"
	set_sensitive=[
		{
			name="cloudflare.tunnel_token"
			value=data.cloudflare_zero_trust_tunnel_cloudflared_token.gke_tunnel_token.token,
		},
		{
			name="image.tag"
			value="2026.2.0",
		},
	]
	values=[
		yamlencode({
			resources={
				limits={
					cpu="200m"
					memory="256Mi",
				}
				requests={
					cpu="100m"
					memory="128Mi",
				}
			},
		}),
	]
}
resource "random_id" "tunnel_secret" {
	byte_length=32
}
