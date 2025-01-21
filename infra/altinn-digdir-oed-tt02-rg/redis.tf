resource "azurerm_redis_cache" "cache" {
  capacity            = 0
  family              = "C"
  location            = var.alt_location
  name                = "oed-${var.environment}-cache"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}
