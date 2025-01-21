resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.37.167.0/24"]
  location            = var.alt_location
  name                = "oed-${var.environment}-feedpoller-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}

