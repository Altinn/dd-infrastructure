resource "azurerm_app_service_plan" "admin_asp" {
  name                = "ASP-altinn-digdir-dd-admin-${var.environment}"
  location            = rg.location
  resource_group_name = rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azuread_application" "dd_admin" {
  display_name = "dd-admin"

  web {
    redirect_uris = [
      "https://${var.app_service_hostname}/.auth/login/aad/callback"
    ]

    implicit_grant {
      id_token_issuance_enabled = true
      access_token_issuance_enabled = false
    }
  }

  optional_claims {
    id {
      name     = "groups"
      essential = false
    }
  }

  api {
    requested_access_token_version = 2
  }
}

# App Service bruker denne ID-en
output "aad_client_id" {
  value = azuread_application.dd_admin.client_id
}

resource "azurerm_linux_web_app" "admin_wa" {
  name                = "dd-${var.environment}-admin-app"
  location            = rg.location
  resource_group_name = rg.name
  https_only          = true
  service_plan_id     = azurerm_app_service_plan.admin_asp.id


  site_config {
    linux_fx_version = "DOTNETCORE|8.0"
    minimum_tls_version = "1.3"
    ftps_state = "FtpsOnly"  # Kreves for publish profile
    application_stack{
      dotnet_version = "9.0"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "RedirectToLoginPage"
    default_provider       = "azure_active_directory"

    active_directory_v2 {
      client_id             = var.aad_client_id
      tenant_auth_endpoint  = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
      allowed_audiences     = [var.aad_client_id]
    }

    login {
      token_store_enabled = true
    }
  }

  tags = {
    costcenter = "altinn3"
    service    = "oed"
    solution   = "apps"
  }
}

resource "azurerm_key_vault_access_policy" "dd_admin_read_secrets" {
  depends_on = [ azurerm_linux_web_app.admin_wa ]
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_linux_web_app.admin_wa.identity[0].tenant_id
  object_id    = azurerm_linux_web_app.admin_wa.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
