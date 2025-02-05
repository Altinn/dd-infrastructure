resource "azurerm_service_plan" "authz" {
  #  app_service_environment_id   = null
  location = var.alt_location
  #  maximum_elastic_worker_count = 1
  name    = "ASP-altinndigdiroedtt02rg-9c68"
  os_type = "Windows"
  #  per_site_scaling_enabled     = false
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B2"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  #  worker_count           = 1
  #  zone_balancing_enabled = false
}
