resource "azurerm_key_vault" "kv" {
  name                = "oed-prod-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = var.tenant_id
}
