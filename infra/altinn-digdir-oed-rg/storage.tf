resource "azurerm_storage_account" "sa" {
  name                     = "oedfeedpollerstrg"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  blob_properties {
    versioning_enabled = true
  }
  #network_rules {
  #default_action             = "Deny"
  #virtual_network_subnet_ids = [azurerm_subnet.default.id]
  #}
  tags = {
    costcenter = "altinn3"
    service    = "oed"
    solution   = "apps"
  }
}

resource "azurerm_storage_management_policy" "sa_version_cleanup_smp" {
  storage_account_id = azurerm_storage_account.sa.id
  rule {
    name    = "delete-old-blob-versions"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = [""]
    }

    actions {
      version {
        delete_after_days_since_creation = 7
      }
    }
  }
}

resource "azurerm_storage_account" "sa_admin_app" {
  name                     = "${var.environment}adminapp"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_table" "st_audit_user" {
  name                 = "audituser"
  storage_account_name = azurerm_storage_account.sa_admin_app.name
}

resource "azurerm_storage_table" "st_audit_estate" {
  name                 = "auditestate"
  storage_account_name = azurerm_storage_account.sa_admin_app.name
}

resource "azurerm_role_assignment" "ra_storage_contributor_admin_app" {
  scope                = azurerm_storage_account.sa_admin_app.id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         =  azurerm_linux_web_app.admin_app.identity[0].principal_id
}

resource "azurerm_redis_cache" "cache" {
  name                = "oed-cache"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}
