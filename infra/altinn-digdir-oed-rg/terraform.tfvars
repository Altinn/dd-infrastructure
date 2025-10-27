environment                = "prod"
rg_name                    = "altinn-digdir-oed-rg"
rg_location                = "norwayeast"
alt_location               = "norwayeast"
tenant_id                  = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
subscription_id            = "0f05e9d4-592b-491a-b9da-49a8b242d0c5"
cluster_fqdn               = "digdir.apps.altinn.no"
platform_fqdn              = "platform.altinn.no"
maskinporten_fqdn          = "maskinporten.no"
domstol_fqdn               = "oppgjoer-etter-doedsfall.apps.ocp.prod.domstol.no"
digdir_kv_sp_object_id     = "570ae202-0655-482f-8aee-f885aa852685"
digdir_altinn3_law_id      = "/subscriptions/0f05e9d4-592b-491a-b9da-49a8b242d0c5/resourceGroups/monitor-digdir-prod-rg/providers/Microsoft.OperationalInsights/workspaces/application-digdir-prod-law"
support_email              = "digitalt-dodsbo-prod-aaaapupmzvtgp4ppcx7ggiaou4@digdir.slack.com"
altinn_apps_digdir_kv_name = "digdir-prod-apps-kv"
altinn_apps_digdir_rg_name = "altinnapps-digdir-prod-rg"
github_action_oid          = "b59ab7b9-db38-4bd3-8614-e6d10ad70b11"
admin_app_user_group_id    = "1d6f4be0-f9fb-4312-a4cb-82d5fdb07dcf"
static_whitelist = [
  {
    name     = "Oekern_office"
    start_ip = "78.41.45.0"
    end_ip   = "78.41.45.0"
  },
  {
    name     = "aks"
    start_ip = "20.100.24.184"
    end_ip   = "20.100.24.185"
  },
  {
    name     = "A3Auth1"
    start_ip = "51.13.20.210"
    end_ip   = "51.13.20.210"
  },
  {
    name     = "A3Auth2"
    start_ip = "51.13.20.208"
    end_ip   = "51.13.20.208"
  },
  {
    name     = "A3-Eventystem"
    start_ip = "20.100.46.139"
    end_ip   = "20.100.46.139"
  }
]
a3_sp_app_name      = "digdir-prod-kv-sp"
fd_sku_name         = "Premium_AzureFrontDoor"
authz_custom_domain = "digitaltdodsbo.altinn.no"

# Entra ID Configuration - Replace with your actual group object IDs
entraid_admin_group_object_id = "c98a0265-fbf9-4890-8a71-50df4623582d"
entraid_read_group_object_id  = "87f6e50d-7423-4368-8d24-991146bfdfd6"
entraid_app_name_suffix       = "adminapp"
entraid_app_name_prefix       = "digdir-dd"
entraid_app_description       = "Digital estate management application with Admin and Read roles"

# SPA Authentication Configuration
entraid_spa_redirect_uri_production  = "https://dd-prod-admin-app.azurewebsites.net/redirect"
