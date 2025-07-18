environment                = "test"
alt_environment            = "tt02"
rg_name                    = "altinn-digdir-oed-tt02-rg"
rg_location                = "norwayeast"
alt_location               = "westeurope"
tenant_id                  = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
subscription_id            = "7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103"
cluster_fqdn               = "digdir.apps.tt02.altinn.no"
platform_fqdn              = "platform.tt02.altinn.no"
maskinporten_fqdn          = "test.maskinporten.no"
domstol_fqdn               = "oppgjoer-etter-doedsfall.apps.ocp.test.domstol.no"
digdir_kv_sp_object_id     = "c28691c7-9899-4e43-8292-86b99b0ed3d8"
digdir_altinn3_law_id      = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/monitor-digdir-tt02-rg/providers/Microsoft.OperationalInsights/workspaces/application-digdir-tt02-law"
support_email              = "digitalt-dodsbo-test-aaaapwt4zc7waueeb6s5s6j2qi@digdir.slack.com"
altinn_apps_digdir_kv_name = "digdir-tt02-apps-kv"
altinn_apps_digdir_rg_name = "altinnapps-digdir-tt02-rg"
github_action_oid          = "b59ab7b9-db38-4bd3-8614-e6d10ad70b11"
admin_app_user_group_id    = "717e682e-95a1-4b0e-a120-d47ebbf6109c"
static_whitelist = [
  {
    name     = "Oekern_office"
    start_ip = "78.41.45.0"
    end_ip   = "78.41.45.0"
  },
  {
    name     = "aks"
    start_ip = "51.13.16.142"
    end_ip   = "51.13.16.143"
  }
]
a3_sp_app_name = "digdir-tt02-kv-sp"
