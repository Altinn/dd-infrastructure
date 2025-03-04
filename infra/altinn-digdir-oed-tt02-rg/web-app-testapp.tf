import {
  to = azurerm_windows_web_app.testapp
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/sites/oed-testapp-app"
}

resource "azurerm_windows_web_app" "testapp" {
  lifecycle {
    ignore_changes = [app_settings["AuthSettings:CloudEventSecret"]]
  }
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                                 = azurerm_application_insights.testapp_ai.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION                            = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                            = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                          = azurerm_application_insights.testapp_ai.connection_string
    "AltinnSettings:Password"                                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--TestTokenGenerator--Password)"
    "AltinnSettings:PlatformUrl"                                   = "https://platform.tt02.altinn.no"
    "AltinnSettings:TokenGeneratorUrl"                             = "https://altinn-testtools-token-generator.azurewebsites.net"
    "AltinnSettings:Username"                                      = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--TestTokenGenerator--Username)"
    ApplicationInsightsAgent_EXTENSION_VERSION                     = "~2"
    "AuthSettings:CloudEventQueryParamName"                        = "code"
    "AuthSettings:Password"                                        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--oed-testapp-password)"
    "AuthSettings:Username"                                        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--oed-testapp-username)"
    DiagnosticServices_EXTENSION_VERSION                           = "~3"
    InstrumentationEngine_EXTENSION_VERSION                        = "disabled"
    "MaskinportenSettings:ClientId"                                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--ClientId)"
    "MaskinportenSettings:EncodedJwk"                              = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--EncodedJwk)"
    "MaskinportenSettings:Environment"                             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--Environment)"
    "MaskinportenSettings:TokenExchangeEnvironment"                = "tt02"
    "OedEventsSettings:BaseAddress"                                = "https://digdir.apps.tt02.altinn.no"    
    SnapshotDebugger_EXTENSION_VERSION                             = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions                = "disabled"
    XDT_MicrosoftApplicationInsights_Java                          = "1"
    XDT_MicrosoftApplicationInsights_Mode                          = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS                        = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk                    = "disabled"
  }
  client_affinity_enabled = true
  tags = {
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.testapp_ai.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.testapp_ai.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.testapp_ai.id
  }
  https_only          = true
  location            = var.alt_location
  name                = "oed-testapp-app"
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
    always_on                         = false
    ftps_state                        = "FtpsOnly"
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v9.0"
      node_version   = "~16"
    }
    virtual_application {
      physical_path = "site\\wwwroot"
      preload       = false
      virtual_path  = "/"
    }
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