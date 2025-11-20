resource "azurerm_service_plan" "feedpoller" {
  name                = "ASP-altinndigdiroed-feedpoller"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"
  sku_name            = "EP1"
  worker_count        = 1
}

resource "azurerm_service_plan" "authz_linux" {
  name                = "ASP-altinndigdiroed-authz-linux"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P0v3"
  worker_count        = 1
}