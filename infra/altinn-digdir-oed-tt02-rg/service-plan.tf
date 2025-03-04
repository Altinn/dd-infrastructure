resource "azurerm_service_plan" "feedpoller" {
  name                = "ASP-altinndigdiroedtt02rg-9144"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "B2"
  worker_count = 1
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}

resource "azurerm_service_plan" "authz" {
  name                = "ASP-altinndigdiroedtt02rg-9c68"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "B2"
  worker_count        = 1
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}
