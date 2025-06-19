import {
  to = azurerm_linux_web_app.easyauth_app
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/sites/dd-test-easyauth-app"
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
      allowed_applications        = ["cdf0585d-b7b4-4d6d-8192-42af06e2745f"]
      allowed_audiences           = ["api://cdf0585d-b7b4-4d6d-8192-42af06e2745f"]
      client_id                   = "cdf0585d-b7b4-4d6d-8192-42af06e2745f"
      client_secret_setting_name  = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint        = "https://sts.windows.net/cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c/v2.0"
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