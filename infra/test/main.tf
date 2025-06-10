resource "azurerm_linux_web_app" "res-0" {
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY             = "e5b3288e-cff4-4369-addb-4af882bde487"
    APPLICATIONINSIGHTS_CONNECTION_STRING      = "InstrumentationKey=e5b3288e-cff4-4369-addb-4af882bde487;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/;LiveEndpoint=https://norwayeast.livediagnostics.monitor.azure.com/;ApplicationId=c9b785f9-2de7-40c8-b646-14431f194718"
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    WEBSITE_AUTH_AAD_ALLOWED_TENANTS           = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
  }
  https_only          = true
  location            = "norwayeast"
  name                = "dd-test-admin-app"
  resource_group_name = "altinn-digdir-oed-tt02-rg"
  service_plan_id     = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/serverFarms/asp-altinndigdir-dd-test-admin"
  tags = {
    costcenter                                       = "altinn3"
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=e5b3288e-cff4-4369-addb-4af882bde487;IngestionEndpoint=https://norwayeast-0.in.applicationinsights.azure.com/;LiveEndpoint=https://norwayeast.livediagnostics.monitor.azure.com/;ApplicationId=c9b785f9-2de7-40c8-b646-14431f194718"
    "hidden-link: /app-insights-instrumentation-key" = "e5b3288e-cff4-4369-addb-4af882bde487"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/dd-test-adminapp-ai"
    solution                                         = "apps"
  }
  auth_settings_v2 {
    auth_enabled           = true
    require_authentication = true
    unauthenticated_action = "Return403"
    active_directory_v2 {
      allowed_applications       = ["83327527-9010-4c48-84d9-5f1b99bba309"]
      allowed_audiences          = ["api://83327527-9010-4c48-84d9-5f1b99bba309"]
      client_id                  = "83327527-9010-4c48-84d9-5f1b99bba309"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c/v2.0"
    }
    login {
      token_store_enabled = true
    }
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on           = false
    minimum_tls_version = "1.3"
  }
  sticky_settings {
    app_setting_names = ["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"]
  }
}
