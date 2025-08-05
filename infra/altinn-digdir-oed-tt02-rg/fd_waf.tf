# 1. Front Door Premium
resource "azurerm_cdn_frontdoor_profile" "fd_profile" {
  name                = "oed-fd-profile"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Premium_AzureFrontDoor"
}

# 2. WAF-policy med IP whitelist
resource "azurerm_cdn_frontdoor_firewall_policy" "waf_policy" {
  name                = "oed-waf-policy"
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
    type     = "MatchRule"
    name     = "AllowOnlyTrustedIP"
    priority = 1
    action   = "Allow"

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = local.whitelist_array
    }
  }

  custom_rule {
    name     = "DenyAllOthers"
    priority = 100
    type     = "MatchRule"
    action   = "Block"

    match_condition {
      match_variable = "RemoteAddr"
      operator       = "IPMatch"
      match_values   = ["0.0.0.0/0"]
    }
  }
}

# 3. Origin group (App Service backend)
resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "oed-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id

  health_probe {
    interval_in_seconds = 240
    path                = "/health"
    protocol            = "Https"
    request_type        = "GET"
  }

  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "app_origin" {
  name                           = "oed-appservice-origin"
  certificate_name_check_enabled = true
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.origin_group.id
  host_name                      = "oed-test-authz-app.azurewebsites.net"
  http_port                      = 80
  https_port                     = 443
  enabled                        = true
  origin_host_header             = "oed-test-authz-app.azurewebsites.net"
}

# 4. Front Door Endpoint
resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "oed-fd-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
}

# 5. Route + WAF-link
resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "default-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin.app_origin.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin_group.origin_group.id]
  supported_protocols           = ["Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "MatchRequest"
  link_to_default_domain        = true
  https_redirect_enabled        = true
}