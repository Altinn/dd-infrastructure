resource "azurerm_log_analytics_workspace" "law" {
  allow_resource_only_permissions         = true
  cmk_for_query_forced                    = false
  daily_quota_gb                          = -1
  data_collection_rule_id                 = null
  immediate_data_purge_on_30_days_enabled = false
  internet_ingestion_enabled              = true
  internet_query_enabled                  = true
  local_authentication_disabled           = false
  location                                = var.alt_location
  name                                    = "Workspace-altinnapps-digdir-oed-${var.alt_environment}-rg-WEU"
  reservation_capacity_in_gb_per_day      = null
  resource_group_name                     = azurerm_resource_group.rg.name
  retention_in_days                       = 30
  sku                                     = "PerGB2018"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}
