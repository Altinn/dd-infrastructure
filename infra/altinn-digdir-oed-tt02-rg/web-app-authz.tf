resource "azurerm_windows_web_app" "authz" {
  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_DAAS_STORAGE_CONNECTIONSTRING"],
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
  app_settings = {
    WEBSITE_DAAS_STORAGE_CONNECTIONSTRING                          = "DefaultEndpointsProtocol=https;AccountName=oedteson39ei;EndpointSuffix=core.windows.net"
    APPINSIGHTS_INSTRUMENTATIONKEY                                 = azurerm_application_insights.authz_ai.instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION                            = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                            = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                          = azurerm_application_insights.authz_ai.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION                     = "~2"
    DiagnosticServices_EXTENSION_VERSION                           = "~3"
    InstrumentationEngine_EXTENSION_VERSION                        = "disabled"
    "GeneralSettings:MaskinportenAuxillaryOauth2WellKnownEndpoint" = "https://${var.maskinporten_fqdn}/.well-known/oauth-authorization-server/"
    "GeneralSettings:MaskinportenOauth2WellKnownEndpoint"          = "https://${var.platform_fqdn}/authentication/api/v1/openid/.well-known/openid-configuration/"
    "GeneralSettings:OedEventAuthQueryParameter"                   = "auth"
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
    "costcenter"                                     = "altinn3"
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.authz_ai.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.authz_ai.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.authz_ai.id
    "solution"                                       = "apps"
  }
  https_only          = true
  location            = var.alt_location
  name                = "oed-${var.environment}-authz-app"
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.authz.id
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = ["/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/oed-kv-principal"]
  }
  logs {
    detailed_error_messages = false
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    always_on                         = true
    health_check_eviction_time_in_min = 10
    health_check_path                 = "/health"
    http2_enabled                     = true
    cors {
      allowed_origins     = ["https://portal.azure.com"]
      support_credentials = false
    }
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
    ip_restriction {
      description = "Allow-FrontDoor"
      service_tag = "AzureFrontDoor.Backend"
      action      = "Allow"
      priority    = 100
    }

    # dynamic "ip_restriction" {
    #   for_each = local.whitelist_map_pg
    #   content {
    #     description = ip_restriction.value.name
    #     ip_address  = ip_restriction.value.start_ip
    #     priority    = 100
    #     action      = "Allow"
    #   }
    # }

    # ip_restriction {
    #   name       = "Deny-All"
    #   ip_address = "0.0.0.0/0"
    #   priority   = 900
    #   action     = "Deny"
    # }
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
