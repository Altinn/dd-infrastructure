variable "environment" {
  type = string
}
variable "alt_environment" {
  type = string
}
variable "rg_location" {
  type = string
}
variable "rg_name" {
  type = string
}
variable "alt_location" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "subscription_id" {
  type = string
}
variable "cluster_fqdn" {
  type = string
}
variable "platform_fqdn" {
  type = string
}
variable "maskinporten_fqdn" {
  type = string
}
variable "domstol_fqdn" {
  type = string
}
variable "digdir_kv_sp_object_id" {
  type = string
}
variable "digdir_altinn3_law_id" {
  type = string
}
variable "support_email" {
  type = string
}
variable "altinn_apps_digdir_kv_name" {
  type = string
}
variable "altinn_apps_digdir_rg_name" {
  type = string
}
variable "github_action_oid" {
  type = string
}
variable "admin_app_user_group_id" {
  type = string
}
variable "static_whitelist" {
  description = "Liste med hardkodede IP-regler"
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
}
variable "a3_sp_app_name" {
  description = "Digdir A3 app principal object name"
  type        = string
}
variable "fd_sku_name" {
  description = "Front door and WAF sku level"
  type        = string
}
variable "authz_custom_domain" {
  description = "custom domene for authz"
  type        = string
}
variable "entraid_admin_group_object_id" {
  description = "Object ID of the existing admin group in Entra ID"
  type        = string
}
variable "entraid_read_group_object_id" {
  description = "Object ID of the existing read group in Entra ID"
  type        = string
}
variable "entraid_app_name_suffix" {
  description = "Suffix for the Entra ID app name (will be prefixed with prefix-dd-{environment}-)"
  type        = string
  default     = "entraid-app"
}
variable "entraid_app_name_prefix" {
  description = "Prefix for the Entra ID app name"
  type        = string
  default     = "digdir-dd"
}
variable "entraid_app_description" {
  description = "Description for the Entra ID application"
  type        = string
  default     = "Application with Admin and Read roles for digital estate management"
}
variable "entraid_spa_redirect_uri_localhost" {
  description = "Localhost redirect URI for SPA authentication (development)"
  type        = string
  default     = "http://localhost:3000/redirect"
}
variable "entraid_spa_redirect_uri_production" {
  description = "Production redirect URI for SPA authentication"
  type        = string
  default     = "https://your-app-domain.com/redirect"
}