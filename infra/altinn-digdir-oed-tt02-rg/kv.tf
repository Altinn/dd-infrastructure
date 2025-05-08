resource "azurerm_key_vault" "kv" {
  name                     = "oed-kv"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  sku_name                 = "standard"
  tenant_id                = var.tenant_id
  purge_protection_enabled = true
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
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

#access til github action brukeren for dd-infrastructure
resource "azurerm_key_vault_access_policy" "github_access" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = var.tenant_id         # Fra iss=
  object_id = var.github_action_oid # oid=

  secret_permissions      = ["Get", "Set", "List"]
  key_permissions         = ["Get", "Set", "List"]
  certificate_permissions = ["Get", "Set", "List"]
}