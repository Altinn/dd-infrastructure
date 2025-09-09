resource "azurerm_storage_account" "sa" {
  name                     = "oed${var.environment}feedpollerstrg"
  location                 = var.alt_location
  resource_group_name      = azurerm_resource_group.rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "StorageV2"
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
        delete_after_days_since_creation = 1
      }
    }
  }
}

resource "azurerm_redis_cache" "cache" {
  name                = "oed-${var.environment}-cache"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}