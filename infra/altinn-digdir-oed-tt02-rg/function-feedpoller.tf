resource "azurerm_windows_function_app" "feedpoller" {
  app_settings = {
    "AzureWebJobs.FeedPoller.Disabled"       = "0"
    "ConnectionStrings:Redis"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=ConnectionStrings--Redis)"
    "DaSettings:ProxyHostEndpointMatch"      = "domstol.no$|brreg.no$|pipedream.net$"
    "MaskinportenSettings:ClientId"          = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedEventsConfig--MaskinportenSettings--ClientId)"
    "MaskinportenSettings:EncodedJwk"        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedEventsConfig--MaskinportenSettings--EncodedJwk)"
    "MaskinportenSettings:Environment"       = "${var.environment}"
    "MaskinportenSettings:DaResource"        = "https://${var.domstol_fqdn}/api"
    "MaskinportenSettings:OedEventsResource" = "https://digdir.apps.altinn.no/digdir/oed-events/da-events/api/v1"
    "MaskinportenSettings:Scope"             = "domstol:forvaltningssaker:doedsfall.read altinn:serviceowner/events altinn:dd:internal"
    "OedSettings:DaProxyHostEndpointMatch"   = "domstol.no$|brreg.no$|pipedream.net$|${var.cluster_fqdn}$"
    "OedSettings:OedEventsBaseUrl"           = "https://${var.cluster_fqdn}/digdir/oed-events/da-events/api/v1/"
    "FUNCTIONS_WORKER_RUNTIME"               = "dotnet-isolated"
    "FUNCTIONS_EXTENSION_VERSION"            = "~4"
  }
  https_only                 = true
  builtin_logging_enabled    = false
  client_certificate_mode    = "Required"
  location                   = var.alt_location
  name                       = "oed-${var.environment}-feedpoller-func"
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.feedpoller.id
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  storage_account_name       = azurerm_storage_account.sa.name
  tags = {
    costcenter                                       = "altinn3"
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.feedpoller.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.feedpoller.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.feedpoller.id
    solution                                         = "apps"
  }
  virtual_network_subnet_id = azurerm_subnet.default.id
  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_insights_connection_string = azurerm_application_insights.feedpoller.connection_string
    application_insights_key               = azurerm_application_insights.feedpoller.instrumentation_key
    ftps_state                             = "FtpsOnly"
    remote_debugging_enabled               = false
    vnet_route_all_enabled                 = true
    use_32_bit_worker                      = false
        
    ip_restriction_default_action = "Deny"
    ip_restriction {
      # Kommasepparert liste over cdir eller ip adresser
      name = "AKS cluster"
      ip_address =  var.aks_cdir
      action = "Allow" 
    }
    ip_restriction {
      name = "Okern office"
      ip_address =  var.okern_office_cdir
      action = "Allow"
    }

    application_stack {
      dotnet_version = "v6.0"
    }
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
  }
}
