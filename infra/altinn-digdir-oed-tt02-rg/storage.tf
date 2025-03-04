resource "azurerm_storage_account" "sa" {
  name                     = "oed${var.environment}feedpollerstrg"
  location                 = var.alt_location
  resource_group_name      = azurerm_resource_group.rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
  account_kind             = "Storage"
  blob_properties {
    versioning_enabled = false
  }
  tags = {
    costcenter = "altinn3"
    service    = "oed"
    solution   = "apps"
  }
}

resource "azurerm_postgresql_flexible_server" "psql" {
  lifecycle {
    ignore_changes = [
      zone,
      high_availability,
      administrator_password
    ]
  }
  administrator_login           = "oed${var.environment}pgadmin"
  administrator_password        = random_password.psql_oedpgadmin.result
  auto_grow_enabled             = false
  backup_retention_days         = 7
  location                      = var.alt_location
  name                          = "oed-${var.environment}-authz-pg"
  public_network_access_enabled = true
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = "B_Standard_B1ms"
  version                       = "14"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
  }
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

import {
  to = azurerm_postgresql_flexible_server_database.oedauthz
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.DBforPostgreSQL/flexibleServers/oed-test-authz-pg/databases/oedauthz"
}

resource "azurerm_postgresql_flexible_server_database" "oedauthz" {
  name      = "oedauthz"
  server_id = azurerm_postgresql_flexible_server.psql.id
  collation = "en_US.utf8"
  charset   = "utf8"
}


#resource "azurerm_key_vault_secret" "psql_connect" {
#  for_each     = toset(["Secrets--PostgreSqlAdminConnectionString", "Secrets--PostgreSqlUserConnectionString"])
#  name         = each.key
#  value        = "Server=${azurerm_postgresql_flexible_server.psql.fqdn};Username=${azurerm_postgresql_flexible_server.psql.administrator_login};Database=oedauthz;Port=5432;Password=${random_password.psql_oedpgadmin.result};SSLMode=Prefer"
#  key_vault_id = azurerm_key_vault.kv.id
#}

resource "azurerm_redis_cache" "cache" {
  name                = "oed-${var.environment}-cache"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}