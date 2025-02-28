resource "azurerm_application_insights" "testapp-ai" {
  application_type    = "web"
  location            = "westeurope"
  name                = "oed-testapp-ai"
  resource_group_name = "altinn-digdir-oed-tt02-rg"
  sampling_percentage = 0
}
resource "azurerm_windows_web_app" "testapp-app" {
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                  = "93935d97-9852-4e58-8732-c66ebdca4bb4"
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING           = "InstrumentationKey=93935d97-9852-4e58-8732-c66ebdca4bb4;IngestionEndpoint=https://westeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=33018710-e6c7-4745-a06a-d1815e06a06a"
    "AltinnSettings:Password"                       = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--TestTokenGenerator--Password)"
    "AltinnSettings:PlatformUrl"                    = "https://platform.tt02.altinn.no"
    "AltinnSettings:TokenGeneratorUrl"              = "https://altinn-testtools-token-generator.azurewebsites.net"
    "AltinnSettings:Username"                       = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--TestTokenGenerator--Username)"
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    "AuthSettings:CloudEventQueryParamName"         = "code"
    "AuthSettings:CloudEventSecret"                 = "54305288-8a8c-4607-9199-66a05cd7b08e"
    "AuthSettings:Password"                         = "Juleni$$enKommer"
    "AuthSettings:Username"                         = "testuser@tt02"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "disabled"
    MICROSOFT_PROVIDER_AUTHENTICATION_SECRET        = "Vrz8Q~KNNMuql5IxLglMLhvZ9n6s93_qs0rUgafy"
    "MaskinportenSettings:ClientId"                 = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--ClientId)"
    "MaskinportenSettings:EncodedJwk"               = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--EncodedJwk)"
    "MaskinportenSettings:Environment"              = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=OedConfig--MaskinportenSettings--Environment)"
    "MaskinportenSettings:TokenExchangeEnvironment" = "tt02"
    "OedEventsSettings:BaseAddress"                 = "https://digdir.apps.tt02.altinn.no"
    SnapshotDebugger_EXTENSION_VERSION              = "disabled"
    WEBSITE_AUTH_AAD_ALLOWED_TENANTS                = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "disabled"
    XDT_MicrosoftApplicationInsights_Java           = "1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS         = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "disabled"
  }
  client_affinity_enabled = true
  location                = "westeurope"
  name                    = "oed-testapp-app"
  resource_group_name     = "altinn-digdir-oed-tt02-rg"
  service_plan_id         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/serverFarms/ASP-altinndigdiroedtt02rg-9c68"
  tags = {
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=93935d97-9852-4e58-8732-c66ebdca4bb4;IngestionEndpoint=https://westeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=33018710-e6c7-4745-a06a-d1815e06a06a"
    "hidden-link: /app-insights-instrumentation-key" = "93935d97-9852-4e58-8732-c66ebdca4bb4"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/oed-testapp-ai"
  }
  auth_settings_v2 {
    default_provider       = "azureactivedirectory"
    require_authentication = true
    active_directory_v2 {
      allowed_applications       = ["ab7fbf8e-3969-4f46-aae3-1c82aed171f8"]
      allowed_audiences          = ["api://ab7fbf8e-3969-4f46-aae3-1c82aed171f8"]
      client_id                  = "ab7fbf8e-3969-4f46-aae3-1c82aed171f8"
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
      tenant_auth_endpoint       = "https://sts.windows.net/cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c/v2.0"
    }
    apple_v2 {
    }
    facebook_v2 {
    }
    github_v2 {
    }
    google_v2 {
    }
    login {
      token_store_enabled = true
    }
    microsoft_v2 {
    }
    twitter_v2 {
    }
  }
  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on                         = false
    ftps_state                        = "FtpsOnly"
    http2_enabled                     = true
    ip_restriction_default_action     = ""
    scm_ip_restriction_default_action = ""
    virtual_application {
      physical_path = "site\\wwwroot"
      virtual_path  = "/"
    }
  }
  sticky_settings {
    app_setting_names = ["MICROSOFT_PROVIDER_AUTHENTICATION_SECRET", "APPINSIGHTS_INSTRUMENTATIONKEY", "APPLICATIONINSIGHTS_CONNECTION_STRING ", "APPINSIGHTS_PROFILERFEATURE_VERSION", "APPINSIGHTS_SNAPSHOTFEATURE_VERSION", "ApplicationInsightsAgent_EXTENSION_VERSION", "XDT_MicrosoftApplicationInsights_BaseExtensions", "DiagnosticServices_EXTENSION_VERSION", "InstrumentationEngine_EXTENSION_VERSION", "SnapshotDebugger_EXTENSION_VERSION", "XDT_MicrosoftApplicationInsights_Mode", "XDT_MicrosoftApplicationInsights_PreemptSdk", "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT", "XDT_MicrosoftApplicationInsightsJava", "XDT_MicrosoftApplicationInsights_NodeJS"]
  }
}
resource "azurerm_windows_web_app" "authz-app" {
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                                 = "c828bbdd-ec6f-4bae-bfcd-3c805406e602"
    APPINSIGHTS_PROFILERFEATURE_VERSION                            = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION                            = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING                          = "InstrumentationKey=c828bbdd-ec6f-4bae-bfcd-3c805406e602;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=b50fb231-6a4d-414d-be5b-1a043d1ddf59"
    ApplicationInsightsAgent_EXTENSION_VERSION                     = "~2"
    DiagnosticServices_EXTENSION_VERSION                           = "~3"
    "GeneralSettings:MaskinportenAuxillaryOauth2WellKnownEndpoint" = "https://test.maskinporten.no/.well-known/oauth-authorization-server/"
    "GeneralSettings:MaskinportenOauth2WellKnownEndpoint"          = "https://platform.tt02.altinn.no/authentication/api/v1/openid/.well-known/openid-configuration/"
    "GeneralSettings:OedEventAuthQueryParameter"                   = "auth"
    InstrumentationEngine_EXTENSION_VERSION                        = "disabled"
    "Secrets:OedEventAuthKey"                                      = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--OedEventAuthKey)"
    "Secrets:PostgreSqlAdminConnectionString"                      = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--PostgreSqlAdminConnectionString)"
    "Secrets:PostgreSqlUserConnectionString"                       = "@Microsoft.KeyVault(VaultName=oed-kv;SecretName=Secrets--PostgreSqlUserConnectionString)"
    SnapshotDebugger_EXTENSION_VERSION                             = "disabled"
    WEBSITE_DAAS_STORAGE_CONNECTIONSTRING                          = "DefaultEndpointsProtocol=https;AccountName=oedteson39ei;EndpointSuffix=core.windows.net"
    XDT_MicrosoftApplicationInsights_BaseExtensions                = "disabled"
    XDT_MicrosoftApplicationInsights_Java                          = "1"
    XDT_MicrosoftApplicationInsights_Mode                          = "recommended"
    XDT_MicrosoftApplicationInsights_NodeJS                        = "1"
    XDT_MicrosoftApplicationInsights_PreemptSdk                    = "disabled"
  }
  https_only          = true
  location            = "westeurope"
  name                = "oed-test-authz-app"
  resource_group_name = "altinn-digdir-oed-tt02-rg"
  service_plan_id     = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/serverFarms/ASP-altinndigdiroedtt02rg-9c68"
  tags = {
    costcenter                                       = "altinn3"
    "hidden-link: /app-insights-conn-string"         = "InstrumentationKey=c828bbdd-ec6f-4bae-bfcd-3c805406e602;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=b50fb231-6a4d-414d-be5b-1a043d1ddf59"
    "hidden-link: /app-insights-instrumentation-key" = "c828bbdd-ec6f-4bae-bfcd-3c805406e602"
    "hidden-link: /app-insights-resource-id"         = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/oed-test-authz-ai"
    solution                                         = "apps"
  }
  identity {
    identity_ids = ["/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/oed-kv-principal"]
    type         = "SystemAssigned, UserAssigned"
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 90
        retention_in_mb   = 35
      }
    }
  }
  site_config {
    health_check_eviction_time_in_min = 10
    health_check_path                 = "/"
    http2_enabled                     = true
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
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
      "XDT_MicrosoftApplicationInsights_NodeJS"
    ]
  }
}
