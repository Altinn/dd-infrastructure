# 1. Front Door
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "oed-fd-profile-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = var.fd_sku_name
}

resource "azurerm_monitor_diagnostic_setting" "fd_logs" {
  name                       = "frontdoor-logs"
  target_resource_id         = azurerm_cdn_frontdoor_profile.fd_profile.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "FrontdoorAccessLog"
  }
  enabled_log {
    category = "FrontdoorWebApplicationFirewallLog"
  }
  enabled_metric {
    category = "AllMetrics"
  }
}

# 2. WAF-policy med Geomatch
resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                = "oedwafpolicy${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = azurerm_cdn_frontdoor_profile.fd_profile.sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    action  = "Block"
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
  }
  managed_rule {
    action  = "Block"
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.1"
  }

  #Spesifikk blokking fra EU/EUS må ligge først
  custom_rule {
    name     = "BlockTestIP"
    priority = 10
    type     = "MatchRule"
    action   = "Block"
    enabled  = false

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = ["82.164.55.142"] # ← erstatt med IP-adressen du vil blokkere
    }
  }

  #GEO open
  custom_rule {
    name     = "AllowEUEOS1"
    priority = 21
    type     = "MatchRule"
    action   = "Allow"
    enabled  = true

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      match_values = [
        # EØS-land (3)
        "IS", "LI", "NO",
        #Andre
        "CH",
        #EU-Land
        "SE", "DK", "FI", "EE", "LV"
      ]
    }
  }

  custom_rule {
    name     = "AllowEUEOS2"
    priority = 22
    type     = "MatchRule"
    action   = "Allow"
    enabled  = true

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      match_values = [
        # EU-land (27)
        "HU", "IE", "IT", "LU", "MT", "NL", "PL", "PT", "RO", "SK"
      ]
    }
  }

  custom_rule {
    name     = "AllowEUEOS3"
    priority = 23
    type     = "MatchRule"
    action   = "Allow"
    enabled  = true

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      match_values = [
        # EU-land (27)
        "SI", "ES"
      ]
    }
  }

  custom_rule {
    name     = "DenyAllOthers"
    priority = 100
    type     = "MatchRule"
    action   = "Block"
    enabled  = false

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = ["0.0.0.0/0"]
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "waf_security_policy" {
  name                     = "oed-fd-security-policy-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf_policy.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.authz_domain.id
        }
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.endpoint.id
        }
        patterns_to_match = ["/*"]
      }
    }
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

# 4. Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "digdir-dd-${var.environment}-authz" #første del av url med fdurl : med "azurefd.net" som postfix
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

# 5. Custom domain
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
  description = "Opprett TXT-record på _dnsauth.var.authz_custom_domain med denne verdien for å validere domene hos Front Door."
}
# TODO: legg inn dette når dns er oppdatert og sertifikat ser ok ut i frontdoor
# digitaltdodsbo.altinn.no CNAME -> ${azurerm_cdn_frontdoor_endpoint.endpoint.host_name}
output "frontdoor_cname_target" {
  value       = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
  description = "Sett CNAME for digitaltdodsbo.altinn.no til denne verdien for cutover."
}

# 6. Route + WAF-link
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app_origin.id]

  # TODO: leg inn dette når dns er oppdatert
  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.authz_domain.id
  ]
  supported_protocols    = ["Https", "Http"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = true
}