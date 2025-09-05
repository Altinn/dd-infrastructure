resource "random_password" "dd_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "dd_user_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "pg" {
  lifecycle {
    ignore_changes = [
      zone
    ]
    prevent_destroy = true
  }
  name                          = "dd-${var.environment}-pg"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  administrator_login           = "pgadmin"
  administrator_password        = random_password.dd_admin_password.result
  version                       = "16"
  sku_name                      = "B_Standard_B2ms"
  storage_mb                    = 32768
  backup_retention_days         = 7
  auto_grow_enabled             = false
  public_network_access_enabled = true

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

# resource "azurerm_postgresql_flexible_server_database" "oed_db" {
#   name      = "dd-oed-${var.environment}-pg-db"
#   server_id = azurerm_postgresql_flexible_server.pg.id
#   charset   = "UTF8"
#   collation = "en_US.utf8"
# }

locals {
  app_user = {
    name     = "appuser"
    password = random_password.dd_user_password.result
  }
}

#Har ikke tilgang til a3 aps kv, så connstringen legges i oed-kv og må flyttes manuelt
resource "azurerm_key_vault_secret" "admin_conn_string" {
  name         = "dd-pgadmin-connection-string"
  value        = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${azurerm_postgresql_flexible_server.pg.administrator_login};Database=${azurerm_postgresql_flexible_server_database.oed_db.name};Port=5432;Password='${random_password.dd_admin_password.result}';SSLMode=Prefer"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "user_conn_string" {
  name         = "OedConfig--Postgres--ConnectionString"
  value        = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${local.app_user.name};Database=${azurerm_postgresql_flexible_server_database.oed_db.name};Port=5432;Password='${local.app_user.password}';SSLMode=Prefer"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "whitelist" {
  depends_on = [local.whitelist_map_pg]
  for_each   = local.whitelist_map_pg

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}
