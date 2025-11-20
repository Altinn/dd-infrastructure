resource "azurerm_linux_web_app" "testapp-linux" {
  name                  = "oed-testapp-app-linux"
  location              = var.alt_location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.authz_linux.id
  depends_on            = [azurerm_service_plan.authz_linux]
  https_only            = true

  lifecycle {
    ignore_changes = [
      app_settings["AuthSettings__CloudEventSecret"],
    ]
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                  = azurerm_application_insights.testapp_ai.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING           = azurerm_application_insights.testapp_ai.connection_string
    "AltinnSettings__Password"                       = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--TestTokenGenerator--Password)"
    "AltinnSettings__PlatformUrl"                    = "https://platform.tt02.altinn.no"
    "AltinnSettings__TokenGeneratorUrl"              = "https://altinn-testtools-token-generator.azurewebsites.net"
    "AltinnSettings__Username"                       = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--TestTokenGenerator--Username)"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    "AuthSettings__CloudEventQueryParamName"         = "code"
    "AuthSettings__Password"                         = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--oed-testapp-password)"
    "AuthSettings__Username"                         = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--oed-testapp-username)"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    "MaskinportenSettings__ClientId"                 = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--ClientId)"
    "MaskinportenSettings__EncodedJwk"               = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--EncodedJwk)"
    "MaskinportenSettings__Environment"              = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--MaskinportenSettings--Environment)"
    "MaskinportenSettings__TokenExchangeEnvironment" = "tt02"
    "OedEventsSettings__BaseAddress"                 = "https://digdir.apps.tt02.altinn.no"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Java           = "1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }
  
  tags = {
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.testapp_ai.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.testapp_ai.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.testapp_ai.id
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

    application_stack {
      dotnet_version = "9.0"
    }
  }
}