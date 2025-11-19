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

# Ingen tilgang til github action bruker
# data "azurerm_key_vault" "a3_kv" {
#   name                = var.altinn_apps_digdir_kv_name
#   resource_group_name = var.altinn_apps_digdir_rg_name
# }

resource "azurerm_key_vault_access_policy" "digdir_kv_sp" {
  depends_on              = [azurerm_key_vault.kv]
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.digdir_kv_sp_object_id
  key_permissions         = ["Get", "List"]
  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "authz_linux" {
  depends_on              = [azurerm_key_vault.kv]
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app.authz_linux.identity[0].principal_id
  secret_permissions      = ["Get"]
}

resource "azurerm_key_vault_access_policy" "testapp_linux" {
  depends_on              = [azurerm_key_vault.kv]
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = azurerm_linux_web_app.testapp-linux.identity[0].principal_id
  secret_permissions      = ["Get"]
}

#access til github action brukeren for dd-infrastructure
resource "azurerm_key_vault_access_policy" "github_access" {
  key_vault_id            = azurerm_key_vault.kv.id
  tenant_id               = var.tenant_id
  object_id               = var.github_action_oid
  key_permissions         = ["Get", "Create", "List", "Delete"]
  secret_permissions      = ["Get", "Set", "List", "Delete", "Purge"]
  certificate_permissions = ["Get", "Create", "List", "Delete"]
}