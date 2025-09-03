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


# resource "azurerm_postgresql_flexible_server" "psql" {
#   lifecycle {
#     ignore_changes  = all
#     prevent_destroy = true
#   }
#   administrator_login = "oed${var.environment}pgadmin"
#   #administrator_password        = random_password.psql_oedpgadmin.result
#   auto_grow_enabled             = false
#   backup_retention_days         = 7
#   location                      = var.alt_location
#   name                          = "oed-${var.environment}-authz-pg"
#   public_network_access_enabled = true
#   resource_group_name           = azurerm_resource_group.rg.name
#   sku_name                      = "B_Standard_B2s"
#   version                       = "16"

#   authentication {
#     active_directory_auth_enabled = true
#     password_auth_enabled         = true
#     tenant_id                     = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
#   }
#   tags = {
#     "costcenter" = "altinn3"
#     "solution"   = "apps"
#   }
# }

# resource "azurerm_postgresql_flexible_server_database" "oedauthz" {
#   lifecycle {
#     ignore_changes = all
#   }
#   name      = "oedauthz"
#   server_id = azurerm_postgresql_flexible_server.psql.id
#   collation = "en_US.utf8"
#   charset   = "utf8"
# }

resource "azurerm_postgresql_flexible_server_firewall_rule" "authz_whitelist" {
  depends_on = [local.whitelist_map_pg]
  for_each   = local.whitelist_map_pg

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.psql.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

resource "azurerm_redis_cache" "cache" {
  name                = "oed-${var.environment}-cache"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}