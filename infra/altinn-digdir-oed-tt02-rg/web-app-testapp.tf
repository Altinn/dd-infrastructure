import {
  to = azurerm_windows_web_app.testapp
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/sites/oed-testapp-app"
}

resource "azurerm_windows_web_app" "testapp" {
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                  = "93935d97-9852-4e58-8732-c66ebdca4bb4"
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING           = "InstrumentationKey=93935d97-9852-4e58-8732-c66ebdca4bb4;IngestionEndpoint=https://westeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=33018710-e6c7-4745-a06a-d1815e06a06a"
    "AltinnSettings:Password"                       = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--TestTokenGenerator--Password)"
    "AltinnSettings:PlatformUrl"                    = "https://platform.tt02.altinn.no"
    "AltinnSettings:TokenGeneratorUrl"              = "https://altinn-testtools-token-generator.azurewebsites.net"
    "AltinnSettings:Username"                       = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--TestTokenGenerator--Username)"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    "AuthSettings:CloudEventQueryParamName"         = "code"
    "AuthSettings:Password"                         = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--oed-testapp-password)"
    "AuthSettings:Username"                         = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--oed-testapp-username)"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET        = "Vrz8Q~KNNMuql5IxLglMLhvZ9n6s93_qs0rUgafy"
    "MaskinportenSettings:ClientId"                 = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--ClientId)"
    "MaskinportenSettings:EncodedJwk"               = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--EncodedJwk)"
    "MaskinportenSettings:Environment"              = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--Environment)"
    "MaskinportenSettings:TokenExchangeEnvironment" = "tt02"
    "OedEventsSettings:BaseAddress"                 = "https://digdir.apps.tt02.altinn.no"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    WEBSITE_AUTH_AAD_ALLOWED_TENANTS                = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Java           = "1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }
  client_affinity_enabled = true
  location                = var.alt_location
  name                    = "oed-testapp-app"
  resource_group_name     = azurerm_resource_group.rg.name
  service_plan_id         = azurerm_service_plan.authz.id
  tags = {
    "costcenter"                                     = "altinn3"
    "solution"                                       = "apps"
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=93935d97-9852-4e58-8732-c66ebdca4bb4;IngestionEndpoint=https://westeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=33018710-e6c7-4745-a06a-d1815e06a06a"
    "hidden-link: /app-insights-instrumentation-key" = "93935d97-9852-4e58-8732-c66ebdca4bb4"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/oed-testapp-ai"
  }
  https_only = true
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
    always_on     = false
    ftps_state    = "FtpsOnly"
    http2_enabled = true
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
      "XDT_MicrosoftApplicationInsights_NodeJS"
    ]
  }
}