resource "azurerm_nat_gateway" "nat" {
  idle_timeout_in_minutes = 4
  location                = var.alt_location
  name                    = "oed-${var.environment}-feedpoller-nat"
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  zones = []
}
