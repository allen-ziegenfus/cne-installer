variable "argocd_namespace" {
  default = "argocd"
  type    = string
}
variable "crossplane_namespace" {
  default = "crossplane-system"
  type    = string
}
variable "external_secrets_namespace" {
  default = "external-secrets"
  type    = string
}


variable "argocd_domain" {
  type    = string
  default = ""
}

variable "argocd_github_webhook_config" {
  description = "Configuration object for ArgoCD authentication and RBAC"
  type = object({
    enable_webhook      = optional(bool, false)
    webhook_secret_name = optional(string, "github-webhook-secret")
  })
  default = {
    enable_webhook      = false
    webhook_secret_name = ""
  }
}

variable "argocd_auth_config" {
  description = "Configuration object for ArgoCD authentication and RBAC"
  type = object({
    enable_sso = optional(bool, false)
    github = optional(object({
      org                       = string
      teams                     = list(string)
      client_id_secret_name     = optional(string, "github-client-id")
      client_secret_secret_name = optional(string, "github-client-secret")
    }))
    rbac = optional(object({
      admins = list(string)
    }))
  })

  default = {
    enable_sso = false
    github     = null
    rbac       = null
  }
}

variable "enable_argocd_ui_tools" {
  default = true
  type    = bool
}

variable "spot" {
  description = "Use spot VMs for all platform pods"
  type        = bool
  default     = true
}