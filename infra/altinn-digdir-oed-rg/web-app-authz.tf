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
  }
  tags = {
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=de242e21-1b67-41d8-80e1-156915e13295;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/;LiveEndpoint=https://norwayeast.livediagnostics.monitor.azure.com/;ApplicationId=b382b5ee-80c0-4b9a-a41b-bc67752e0c61"
    "hidden-link: /app-insights-instrumentation-key" = "de242e21-1b67-41d8-80e1-156915e13295"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/0f05e9d4-592b-491a-b9da-49a8b242d0c5/resourceGroups/altinn-digdir-oed-rg/providers/microsoft.insights/components/oed-authz-ai"
  }
  https_only          = true
  location            = azurerm_resource_group.rg.location
  name                = "oed-authz-app"
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.authz.id
  identity {
    type = "SystemAssigned"
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = false
    http_logs {
      file_system {
        retention_in_days = 5
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    health_check_eviction_time_in_min = 10
    health_check_path                 = "/health"
    http2_enabled                     = true
    #application_stack {
    #  dotnet_version                  = "v8.0"
    #}
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
