locals {
  app_hostname = "dd-${var.environment}-admin-app.azurewebsites.net"
}

resource "azuread_application" "admin_app_reg" {
  display_name            = "dd-${var.environment}-admin-app"
  owners                  = [data.azurerm_client_config.current.object_id]
  group_membership_claims = ["All"] # Include group membership claims in the token
  # This is required to allow the app to read group memberships of users
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b" # GroupMember.Read.All
      type = "Scope"
    }
  }
  web {
    redirect_uris = [
      "https://${local.app_hostname}/.auth/login/aad/callback"
    ]
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }
}

resource "azuread_service_principal" "admin_app_sp" {
  client_id = azuread_application.admin_app_reg.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_password" "admin_app_secret_V2" {
  application_id = azuread_application.admin_app_reg.id
  display_name   = azuread_application.admin_app_reg.display_name
}

resource "azurerm_key_vault_secret" "aad_secret" {
  name         = "OedAdmin--MicrosoftProviderAuthSecret"
  value        = azuread_application_password.admin_app_secret_V2.value
  key_vault_id = azurerm_key_vault.kv.id
}

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
    "DOTNET_ENVIRONMENT"                         = "Production"
    "ASPNETCORE_ENVIRONMENT"                     = "Production"
    "ConnectionStrings__OedDb"                   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedConfig--Postgres--ConnectionString)"
    "ConnectionStrings__OedAuthzDb"              = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=Secrets--PostgreSqlUserConnectionString)"
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.adminapp_ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.adminapp_ai.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"           = var.tenant_id
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"   = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=${azurerm_key_vault_secret.aad_secret.name})"
    "MaskinportenSettings__ClientId"             = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--ClientId)"
    "MaskinportenSettings__Environment"          = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--Environment)"
    "MaskinportenSettings__EncodedJwk"           = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--MaskinportenSettings--EncodedJwk)"
    "AltinnSettings__PlatformUrl"                = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=OedAdmin--AltinnSettings--PlatformUrl)"
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
    always_on = true
  }

  identity {
    type = "SystemAssigned"
  }

  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    default_provider       = "azureactivedirectory"
    unauthenticated_action = "RedirectToLoginPage"
    excluded_paths         = ["/health", "/scalar"]

    active_directory_v2 {
      client_id                  = azuread_application.admin_app_reg.client_id
      tenant_auth_endpoint       = "https://login.microsoftonline.com/${var.tenant_id}/v2.0/"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      #allowed_groups             = [var.admin_app_user_group_id]
    }

    login {
      token_store_enabled = true
    }
  }
}

output "admin_app_url" {
  value = "https://${azurerm_linux_web_app.admin_app.default_hostname}"
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

# Legger client secret som har utløpsdato i keyvault slik at vi kan følge opp.
resource "azurerm_key_vault_secret" "admin_app_client_secret" {
  depends_on      = [azuread_application_password.admin_app_secret_V2]
  name            = "dd-admin-app-client-secret"
  value           = azuread_application_password.admin_app_secret_V2.value
  expiration_date = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", azuread_application_password.admin_app_secret_V2.end_date)
  not_before_date = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", azuread_application_password.admin_app_secret_V2.start_date)
  key_vault_id    = azurerm_key_vault.kv.id
}
