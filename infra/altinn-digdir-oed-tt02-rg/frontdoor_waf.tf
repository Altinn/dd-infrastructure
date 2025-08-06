# 1. Front Door Premium
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "oed-fd-profile-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"
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

  custom_rule {
    name     = "AllowEUEØS"
    priority = 1
    type     = "MatchRule"
    action   = "Allow"
    enabled  = true

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "GeoMatch"
      match_values = [
        # EU-land (27)
        "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR",
        "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE",

        # EØS-land (3)
        "IS", "LI", "NO",

        #Andre
        "CH"
      ]
    }
  }

  custom_rule {
    name     = "DenyAllOthers"
    priority = 100
    type     = "MatchRule"
    action   = "Block"
    enabled  = true

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = ["0.0.0.0/0"]
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

# 5. Route + WAF-link
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app_origin.id]
  supported_protocols           = ["Https", "Http"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "MatchRequest"
  link_to_default_domain        = true
  https_redirect_enabled        = true
  
}