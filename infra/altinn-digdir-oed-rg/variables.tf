variable "environment" {
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

variable "aks_cdir" {
  type    = string
  default = "AKS clusters outbound cdir address"
}
variable "okern_office_cdir" {
  type    = string
  default = "Økern office outbound cdir address"
}
