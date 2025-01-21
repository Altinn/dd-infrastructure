resource "azurerm_key_vault" "kv" {
  location                 = "norwayeast"
  name                     = "oed-kv"
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "standard"
  purge_protection_enabled = true
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  tenant_id = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
}
