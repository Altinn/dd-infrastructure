resource "azurerm_service_plan" "admin_asp" {
  name                = "asp-altinndigdir-dd-${var.environment}-admin"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "admin_app" {
  depends_on = [azurerm_service_plan.admin_asp]
  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-resource-id"]
    ]
  }
  name                = "dd-${var.environment}-admin-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.admin_asp.id
  https_only          = true

  app_settings = {
    "DOTNET_ENVIRONMENT"                         = "Staging"
    "ASPNETCORE_ENVIRONMENT"                     = "Staging"
    "ConnectionStrings__OedDb"                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--Postgres--ConnectionString)"
    "ConnectionStrings__OedAuthzDb"              = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlUserConnectionString)"
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.adminapp_ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.adminapp_ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "AzureEntraId__ClientId"                     = azuread_application.admin_ad_app.client_id
    "MaskinportenSettings__ClientId"             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--ClientId)"
    "MaskinportenSettings__Environment"          = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--Environment)"
    "MaskinportenSettings__EncodedJwk"           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--EncodedJwk)"
    "AltinnSettings__PlatformUrl"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--AltinnSettings--PlatformUrl)"
    "FeedPoller__HostKey"                        = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--FeedPoller--HostKey)"
  }

  tags = {
    "costcenter"                                     = "altinn3"
    "solution"                                       = "apps"
    "hidden-link: /app-insights-conn-string"         = azurerm_application_insights.adminapp_ai.connection_string
    "hidden-link: /app-insights-instrumentation-key" = azurerm_application_insights.adminapp_ai.instrumentation_key
    "hidden-link: /app-insights-resource-id"         = azurerm_application_insights.adminapp_ai.id
  }

  site_config {
    minimum_tls_version = "1.3"
    application_stack {
      dotnet_version = "10.0"
    }
    always_on = true
  }

  identity {
    type = "SystemAssigned"
  }

  # No App Service authentication: the app authenticates with MSAL and validates JWT bearer tokens itself.
}

#Access til systembruker for å lese secrets direkte fra oed keyvault
resource "azurerm_key_vault_access_policy" "dd_admin_read_secrets" {
  depends_on   = [azurerm_linux_web_app.admin_app]
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_linux_web_app.admin_app.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.admin_app.identity[0].principal_id

  key_permissions         = ["Get", "List"]
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

# Ingen tilgang til github action bruker
# Access til systembruker for å lese secrets direkte fra a3 keyvault
# resource "azurerm_key_vault_access_policy" "admin_app_system_user_a3_kvap" {
#   depends_on              = [data.azurerm_key_vault.a3_kv]
#   key_vault_id            = data.azurerm_key_vault.a3_kv.id
#   tenant_id               = data.azurerm_client_config.current.tenant_id
#   object_id               = azurerm_linux_web_app.admin_app.identity[0].principal_id
#   key_permissions         = ["Get", "List"]
#   secret_permissions      = ["Get", "List"]
#   certificate_permissions = ["Get", "List"]
# }
