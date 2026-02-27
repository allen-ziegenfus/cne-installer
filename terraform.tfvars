# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL ADVANCED CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

# Authorized Networks: Restrict GKE API access to your specific IP address.
# Example: "1.2.3.4/32"
# authorized_ipv4_cidr_block = ""

# Custom Domains: Provide a list of domains for routing.
# Example: ["example.com", "myportal.io"]
# domains = []

# ArgoCD Domain: Specifically for accessing the ArgoCD UI.
# argocd_domain = "argocd.example.com"

# ArgoCD Auth: Enable GitHub SSO and RBAC.
# argocd_auth_config = {
#   enable_sso = true
#   github = {
#     org   = "your-github-org"
#     teams = ["your-admin-team"]
#   }
#   rbac = {
#     admins = ["your-github-username"]
#   }
# }

# ArgoCD Webhook: Enable instant syncing on GitHub push.
# argocd_github_webhook_config = {
#   enable_webhook = true
# }

# Cloudflare Integration: Enable Zero Trust Tunneling and DNS management.
# enable_cloudflare     = false
# cloudflare_account_id = ""
# cloudflare_zone_id    = ""

# ---------------------------------------------------------------------------------------------------------------------
# AUTOMATED SETTINGS
# (Do not edit these manually; they are handled by the installer)
# ---------------------------------------------------------------------------------------------------------------------
# project_id   = ""
# region       = ""
