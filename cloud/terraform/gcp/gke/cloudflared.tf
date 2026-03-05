module "cloudflare" {
	cloudflare_account_id=var.cloudflare_account_id
	cloudflare_zone_id=var.cloudflare_zone_id
	count=var.enable_cloudflare ? 1 : 0
	deployment_name=var.deployment_name
	domains=var.domains
	source="./modules/cloudflare"
}
