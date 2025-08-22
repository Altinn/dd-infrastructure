# 1. Front Door (STANDARD)
resource "azurerm_cdn_frontdoor_profile" "fd_profile2" {
  name                = "oed-fd-profile-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.fd_sku_name
}

# 2. Logging
resource "azurerm_monitor_diagnostic_setting" "fd_logs2" {
  name                       = "frontdoor-logs2"
  target_resource_id         = azurerm_cdn_frontdoor_profile.fd_profile2.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "FrontdoorAccessLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# 3. Origin group (App Service backend)
resource "azurerm_cdn_frontdoor_origin_group" "origin_group2" {
  name                     = "oed-origin-group2-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile2.id

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "app_origin2" {
  name                           = "oed-appservice-origin2-${var.environment}"
  certificate_name_check_enabled = true
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.origin_group2.id
  host_name                      = azurerm_windows_web_app.authz.default_hostname
  http_port                      = 80
  https_port                     = 443
  enabled                        = true
  origin_host_header             = azurerm_windows_web_app.authz.default_hostname
}

# 4. Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint2" {
  name                     = "digdir-dd-${var.environment}-authz2"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile2.id
}

# 5. Custom domain (managed TLS støttes også på Standard)
resource "azurerm_cdn_frontdoor_custom_domain" "authz_domain" {
  name                     = "authzdigitaltdodsbo2${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile2.id
  host_name                = var.authz_custom_domain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

output "frontdoor_dns_validation_txt_name" {
  value = "_dnsauth.${var.authz_custom_domain}"
}

output "frontdoor_dns_validation_txt_value" {
  value       = azurerm_cdn_frontdoor_custom_domain.authz_domain.validation_token
  description = "Opprett TXT-record på _dnsauth.digitaltdodsbo.tt02.altinn.no med denne verdien for å validere domene hos Front Door."
}

output "frontdoor_cname_target" {
  value       = azurerm_cdn_frontdoor_endpoint.endpoint2.host_name
  description = "Sett CNAME for digitaltdodsbo.tt02.altinn.no til denne verdien for cutover."
}

# 6. Route
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route2-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint2.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group2.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app_origin2.id]

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.authz_domain.id
  ]

  supported_protocols    = ["Https", "Http"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
  patterns_to_match      = ["/*"]
  link_to_default_domain = true
}
