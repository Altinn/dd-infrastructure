resource "azurerm_windows_web_app" "authz" {
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                                 = azurerm_application_insights.authz_ai.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION                            = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                            = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                          = azurerm_application_insights.authz_ai.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION                     = "~2"
    DiagnosticServices_EXTENSION_VERSION                           = "~3"
    "GeneralSettings:MaskinportenAuxillaryOauth2WellKnownEndpoint" = "https://${var.maskinporten_fqdn}/.well-known/oauth-authorization-server/"
    "GeneralSettings:MaskinportenOauth2WellKnownEndpoint"          = "https://${var.platform_fqdn}/authentication/api/v1/openid/.well-known/openid-configuration/"
    "GeneralSettings:OedEventAuthQueryParameter"                   = "auth"
    InstrumentationEngine_EXTENSION_VERSION                        = "disabled"
    "Secrets:OedEventAuthKey"                                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--OedEventAuthKey)"
    "Secrets:PostgreSqlAdminConnectionString"                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlAdminConnectionString)"
    "Secrets:PostgreSqlUserConnectionString"                       = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlUserConnectionString)"
    SnapshotDebugger_EXTENSION_VERSION                             = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions                = "disabled"
    XDT_MicrosoftApplicationInsights_Java                          = "1"
    XDT_MicrosoftApplicationInsights_Mode                          = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS                        = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk                    = "disabled"
    "WEBSITE_DAAS_STORAGE_CONNECTIONSTRING"                        = "DefaultEndpointsProtocol=https;AccountName=oedteson39ei;EndpointSuffix=core.windows.net"
  }
  tags = {
    "costcenter"                                     = "altinn3"
    "solution"                                       = "apps"
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=c828bbdd-ec6f-4bae-bfcd-3c805406e602;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=b50fb231-6a4d-414d-be5b-1a043d1ddf59"
    "hidden-link: /app-insights-instrumentation-key" = "c828bbdd-ec6f-4bae-bfcd-3c805406e602"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/oed-test-authz-ai"
  }
  https_only          = true
  location            = var.alt_location
  name                = "oed-${var.environment}-authz-app"
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.authz.id
  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/oed-kv-principal",
    ]
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    health_check_eviction_time_in_min = 10
    health_check_path                 = "/"
    http2_enabled                     = true
  }
  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPLICATIONINSIGHTS_CONNECTION_STRING ",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "XDT_MicrosoftApplicationInsightsJava",
      "XDT_MicrosoftApplicationInsights_NodeJS",
    ]
  }
}
