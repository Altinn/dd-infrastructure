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
