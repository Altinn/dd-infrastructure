locals {
  app_hostname = "dd-test-easyauth-app-cggdg2ekf9agf8fk.norwayeast-01.azurewebsites.net"
}

resource "azuread_application" "easyauth_app_reg" {
  display_name            = "dd-${var.environment}-easyauth-app"
  owners                  = [data.azurerm_client_config.current.object_id]
  group_membership_claims = ["SecurityGroup"] # Include group membership claims in the token
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

resource "azuread_service_principal" "easyauth_app_sp" {
  client_id = azuread_application.easyauth_app_reg.client_id
  owners    = [data.azurerm_client_config.current.object_id]
}

resource "azuread_application_password" "easyauth_app_secret_V2" {
  application_id = azuread_application.easyauth_app_reg.id
  display_name   = azuread_application.easyauth_app_reg.display_name
}

resource "azurerm_linux_web_app" "easyauth_app" {
  lifecycle {
    ignore_changes = [
      app_settings["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"],
      app_settings["WEBSITE_AUTH_AAD_ALLOWED_TENANTS"],
      site_config[0].ip_restriction_default_action,
      site_config[0].scm_ip_restriction_default_action,
    ]
  }
  name                                           = "dd-${var.environment}-easyauth-app"
  service_plan_id                                = azurerm_service_plan.admin_asp.id
  resource_group_name                            = azurerm_resource_group.rg.name
  location                                       = azurerm_resource_group.rg.location
  https_only                                     = true
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  sticky_settings {
    app_setting_names = [
      "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET",
    ]
  }

  site_config {
    always_on        = true
    app_command_line = "dotnet dd-test-easyauth-app.dll"
    ftps_state       = "FtpsOnly"
    application_stack {
      dotnet_version = "8.0"
    }
  }

  auth_settings_v2 {
    auth_enabled             = true
    require_authentication   = true
    default_provider         = "AzureActiveDirectory"
    forward_proxy_convention = "NoProxy"
    http_route_api_prefix    = "/.auth"
    runtime_version          = "~1"
    unauthenticated_action   = "RedirectToLoginPage"
    active_directory_v2 {
      allowed_applications        = [azuread_application.easyauth_app_reg.client_id]
      allowed_audiences           = ["api://${azuread_application.easyauth_app_reg.client_id}"]
      client_id                   = azuread_application.easyauth_app_reg.client_id
      client_secret_setting_name  = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint        = "https://sts.windows.net/${var.tenant_id}/v2.0"
      www_authentication_disabled = false
    }
    login {
      cookie_expiration_convention      = "FixedTime"
      cookie_expiration_time            = "08:00:00"
      logout_endpoint                   = "/.auth/logout"
      nonce_expiration_time             = "00:05:00"
      preserve_url_fragments_for_logins = false
      token_refresh_extension_time      = 72
      token_store_enabled               = true
      validate_nonce                    = true
    }
  }
}