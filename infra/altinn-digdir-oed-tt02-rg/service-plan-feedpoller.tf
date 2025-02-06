resource "azurerm_service_plan" "feedpoller" {
  #  app_service_environment_id   = null
  location = var.alt_location
  #  maximum_elastic_worker_count = 20
  name    = "ASP-altinndigdiroedtt02rg-9144"
  os_type = "Windows"
  #  per_site_scaling_enabled     = false
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "EP1"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  #  worker_count           = 1
  #  zone_balancing_enabled = false
  application_stack = {
    dotnet_version = "v6.0"
  }
}
