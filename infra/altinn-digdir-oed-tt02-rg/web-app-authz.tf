resource "azurerm_linux_web_app" "authz_linux" {
  name                  = "oed-${var.environment}-authz-app-${random_integer.ri.result}"
  location              = var.alt_location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.authz_linux.id
  depends_on            = [azurerm_service_plan.authz_linux]
  https_only            = true
  app_settings = {
    //WEBSITE_DAAS_STORAGE_CONNECTIONSTRING                          = "DefaultEndpointsProtocol=https;AccountName=oedteson39ei;EndpointSuffix=core.windows.net"
    APPINSIGHTS_INSTRUMENTATIONKEY                                 = azurerm_application_insights.authz_ai.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION                            = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                            = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                          = azurerm_application_insights.authz_ai.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION                     = "~2"
    DiagnosticServices_EXTENSION_VERSION                           = "~3"
    InstrumentationEngine_EXTENSION_VERSION                        = "disabled"
    "GeneralSettings__MaskinportenAuxillaryOauth2WellKnownEndpoint" = "https://${var.maskinporten_fqdn}/.well-known/oauth-authorization-server/"
    "GeneralSettings__MaskinportenOauth2WellKnownEndpoint"          = "https://${var.platform_fqdn}/authentication/api/v1/openid/.well-known/openid-configuration/"
    "GeneralSettings__OedEventAuthQueryParameter"                   = "auth"
    "Secrets__OedEventAuthKey"                                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--OedEventAuthKey)"
    "Secrets__PostgreSqlAdminConnectionString"                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlAdminConnectionString)"
    "Secrets__PostgreSqlUserConnectionString"                       = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlUserConnectionString)"
    SnapshotDebugger_EXTENSION_VERSION                             = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions                = "disabled"
    XDT_MicrosoftApplicationInsights_Java                          = "1"
    XDT_MicrosoftApplicationInsights_Mode                          = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS                        = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk                    = "disabled"
  }
  tags = {
    "costcenter"                                     = "altinn3"
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.authz_ai.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.authz_ai.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.authz_ai.id
    "solution"                                       = "apps"
  }
  
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = ["/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/oed-kv-principal"]
  }

  site_config { 
    always_on                         = false
    minimum_tls_version               = "1.2"
    health_check_eviction_time_in_min = 10
    health_check_path                 = "/health"
    http2_enabled                     = true
    ip_restriction_default_action     = "Deny"

    application_stack {
      dotnet_version = "10.0"
    }

    ip_restriction {
      name        = "Allow-FrontDoor"
      description = "Allow-FrontDoor"
      service_tag = "AzureFrontDoor.Backend"
      action      = "Allow"
      headers {
        x_azure_fdid = ["${azurerm_cdn_frontdoor_profile.fd_profile.resource_guid}"]
      }
      priority    = 10
    }
  }
}