# 1. Front Door (STANDARD)
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "oed-fd-profile-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.fd_sku_name
}

# 2. Logging
resource "azurerm_monitor_diagnostic_setting" "fd_logs" {
  name                       = "frontdoor-logs"
  target_resource_id         = azurerm_cdn_frontdoor_profile.fd_profile.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "FrontdoorAccessLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# 3. Origin group (App Service backend)
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "oed-origin-group-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "app_origin" {
  name                           = "oed-appservice-origin-${var.environment}"
  certificate_name_check_enabled = true
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.origin_group.id
  host_name                      = azurerm_windows_web_app.authz.default_hostname
  http_port                      = 80
  https_port                     = 443
  enabled                        = true
  origin_host_header             = azurerm_windows_web_app.authz.default_hostname
}

# 4. Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "digdir-dd-${var.environment}-authz"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

# 5. Custom domain (managed TLS støttes også på Standard)
resource "azurerm_cdn_frontdoor_custom_domain" "authz_domain" {
  name                     = "authzdigitaltdodsbo${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
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
  description = "Opprett TXT-record på _dnsauth.${var.authz_custom_domain} med denne verdien for å validere domene hos Front Door."
}

output "frontdoor_cname_target" {
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
  description = "Sett CNAME for test-digitaltdodsbo.altinn.no til denne verdien for cutover."
}

# 6. Route
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app_origin.id]

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.authz_domain.id
  ]

  supported_protocols    = ["Https", "Http"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
  patterns_to_match      = ["/*"]
  link_to_default_domain = true
}
