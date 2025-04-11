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
  description = "Id'n til den felles law resursen som altinn3 apper bruker"
}
variable "support_email" {
  type = string
  description = "epost adresse til en dedikert slack kanal, som alarmer sendes til"
}
variable "ip_whitelist" {
  type = list(string)
  description = "Liste over ip adresser som skal ha tilgang til resurser"
  validation {
    condition     = alltrue([for ip in var.ip_whitelist : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+(\\/\\d+)?$", ip))])
    error_message = "Alle elementer i ip_whitelist må være gyldige IPv4-adresser med optional CIDR."
  }
}

variable "slack_webhook_url" {
  type      = string
  sensitive = true
}

variable "law_resources" {
  description = "List of Log Analytics Workspace ARM IDs"
  type        = list(string)
}

variable "ai_resources" {
  description = "List of Application Insights ARM IDs"
  type        = list(string)
}