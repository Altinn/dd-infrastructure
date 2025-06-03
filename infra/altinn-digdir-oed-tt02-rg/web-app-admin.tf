data "azuread_group" "developers" {
  display_name = var.admin_app_user_groupname
}

resource "azurerm_service_plan" "admin_asp" {
  name                = "ASP altinndigdir-dd-${var.environment}-admin"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "admin_app" {
  name                = "dd-${var.environment}-admin-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.admin_asp.id
  https_only          = true
  tags = {

    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
  site_config {
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
    default_provider       = "azureactivedirectory"

    active_directory_v2 {
      client_id            = data.azurerm_client_config.current.client_id
      tenant_auth_endpoint = "https://login.microsoftonline.com/${var.tenant_id}/v2.0/"
      allowed_groups       = [data.azuread_group.developers.display_name]
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
