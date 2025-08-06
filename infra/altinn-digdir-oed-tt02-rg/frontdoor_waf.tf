locals {
  authz_custom_hostname = "test-digitaltdodsbo.altinn.no" #TODO: endre denne i prod
}

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
    name     = "AllowEUEOS1"
    priority = 1
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
        "CH", "LI",
        #EU-Land
        "SE", "DK", "FI", "EE", "LV"
      ]
    }
  }

  custom_rule {
    name     = "AllowEUEOS2"
    priority = 2
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
    priority = 3
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
    enabled  = true

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
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.authz_domain.id #azurerm_cdn_frontdoor_endpoint.endpoint.id
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

# 5. Route + WAF-link
resource "azurerm_cdn_frontdoor_route" "route" {
  name                            = "default-route-${var.environment}"
  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids        = [azurerm_cdn_frontdoor_origin.app_origin.id]
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.authz_domain.id]
  supported_protocols             = ["Https", "Http"]
  patterns_to_match               = ["/*"]
  forwarding_protocol             = "HttpsOnly"
  link_to_default_domain          = true
  https_redirect_enabled          = true
}

# 6. Custom doamin test-digitaltdodsbo.altinn.no
resource "azurerm_dns_zone" "authz_dz" {
  name                = locals.authz_custom_hostname
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_cdn_frontdoor_custom_domain" "authz_domain" {
  name                     = "authz_custom_domain_${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd_profile.id
  dns_zone_id              = azurerm_dns_zone.authz_dz.id
  host_name                = locals.authz_custom_domain

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_dns_txt_record" "authz_txt" {
  name                = join(".", ["_dnsauth", locals.authz_custom_hostname])
  zone_name           = azurerm_dns_zone.authz_dz.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 60 #TODO: endre til 3600 senere
  record {
    value = azurerm_cdn_frontdoor_custom_domain.authz_domain.validation_token
  }
}

resource "azurerm_dns_cname_record" "authz_cname" {
  depends_on = [azurerm_cdn_frontdoor_route.route, azurerm_cdn_frontdoor_security_policy.waf_security_policy]

  name                = "authz_custom_domain_cname_${var.environment}"
  zone_name           = azurerm_dns_zone.authz_dz.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 60 #TODO: endre til 3600 senere
  record              = azurerm_cdn_frontdoor_endpoint.endpoint.host_name
}