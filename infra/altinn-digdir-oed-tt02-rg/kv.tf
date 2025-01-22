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

resource "azurerm_key_vault_access_policy" "digdir_kv_sp" {
  depends_on              = [azurerm_key_vault.kv]
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.digdir_kv_sp_object_id
  key_permissions         = ["Get", "List"]
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}
