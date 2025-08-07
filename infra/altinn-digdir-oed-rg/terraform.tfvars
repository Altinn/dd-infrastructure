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
  }
]
a3_sp_app_name = "digdir-prod-kv-sp"
fd_sku_name    = "Premium_AzureFrontDoor"
authz_custom_domain = "digitaltdodsbo.altinn.no"