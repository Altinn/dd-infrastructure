resource "azurerm_cdn_frontdoor_profile" "authz_fd_profile" {
  name                = "fd-authz-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

# Enables i prod?
# resource "azurerm_cdn_frontdoor_custom_domain" "authz_fd_domain" {
#   name                      = "digitaltdodsbo-altinn-no"
#   cdn_frontdoor_profile_id  = azurerm_cdn_frontdoor_profile.authz_fd_profile.id
#   host_name                 = "digitaltdodsbo.altinn.no"
#   tls {
#     certificate_type      = "ManagedCertificate"
#   }
# }

resource "azurerm_cdn_frontdoor_endpoint" "authz_fd_endpoint" {
  name                     = "oed-${var.environment}-authz-app" #TODO: Endre denne for prod
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.authz_fd_profile.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_firewall_policy_link" "authz_fd_waf_link" {
  cdn_frontdoor_endpoint_id        = azurerm_cdn_frontdoor_endpoint.authz_fd_endpoint.id
  cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.authz_waf.id
}

resource "azurerm_cdn_frontdoor_origin_group" "authz_fd_og" {
  name                     = "authz-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.authz_fd_profile.id

  # ❖ Load-balancing verdier kan stå på 0/standard hvis du kun har én origin
  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 4
    successful_samples_required        = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/health"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "authz_fd_origin" {
  name                          = "authz-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.authz_fd_og.id
  host_name                     = azurerm_windows_web_app.authz.default_hostname
  origin_host_header            = azurerm_windows_web_app.authz.default_hostname
  http_port                     = 80
  https_port                    = 443
  enabled                       = true
  priority                      = 1
  weight                        = 1000

  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_firewall_policy" "authz_waf" {
  name                = "waf-authz-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard_AzureFrontDoor"
  mode                = "Detection" #|Prevention, TODO: Endre denne
  enabled             = true

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block" #|Allow, Log, Redirect, or Block
  }

  tags = {
    solution = "apps"
  }
}

resource "azurerm_cdn_frontdoor_route" "authz_fd_route" {
  name                          = "authz-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.authz_fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.authz_fd_og.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.authz_fd_origin.id]
  # For prod, uncomment the following lines
#   cdn_frontdoor_custom_domain_ids = [
#     azurerm_cdn_frontdoor_custom_domain.authz_fd_domain.id
#   ]

  forwarding_protocol    = "HttpsOnly"
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Https"]
  enabled                = true
  link_to_default_domain = true
}

output "frontdoor_endpoint_hostname" {
  value = azurerm_cdn_frontdoor_endpoint.authz_fd_endpoint.host_name
}