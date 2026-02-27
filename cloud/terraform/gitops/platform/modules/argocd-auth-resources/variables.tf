variable "argocd_auth_config" {
  type = object({
    enable_sso = optional(bool, false)
    github = object({
      org                       = string
      teams                     = list(string)
      client_id_secret_name     = string
      client_secret_secret_name = string
    })
    rbac = object({
      admins = list(string)
    })
  })
}