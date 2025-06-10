data "azurerm_key_vault_secret" "adminapp_client_secret" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = "DDAdminapp--ClientSecret"
}

resource "azurerm_service_plan" "admin_asp" {
  name                = "asp-altinndigdir-dd-${var.environment}-admin"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

data "azuread_application" "admin_app_application" {
  display_name = "dd-${var.environment}-admin-app"
}

resource "azurerm_linux_web_app" "admin_app" {
  depends_on          = [azurerm_service_plan.admin_asp]
  name                = "dd-${var.environment}-admin-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.admin_asp.id
  https_only          = true

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.adminapp_ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.adminapp_ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"           = var.tenant_id
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"   = data.azurerm_key_vault_secret.adminapp_client_secret.value
  }

  sticky_settings {
    app_setting_names       = ["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"]
    connection_string_names = [""]
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
      dotnet_version = "9.0"
    }
    always_on = false
  }

  identity {
    type = "SystemAssigned"
  }
  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "Return403"
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      allowed_applications       = [data.azuread_application.admin_app_application.client_id]
      allowed_audiences          = ["api://${data.azuread_application.admin_app_application.client_id}"]
      client_id                  = data.azuread_application.admin_app_application.client_id
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/${var.tenant_id}/v2.0/"
      allowed_groups             = [var.admin_app_user_group_id]
    }

    login {
      token_store_enabled = true
    }
  }
}

resource "azurerm_key_vault_access_policy" "dd_admin_read_secrets" {
  depends_on   = [azurerm_linux_web_app.admin_app]
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_linux_web_app.admin_app.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.admin_app.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
