resource "random_password" "dd_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "dd_user_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                   = "dd-tt02-pg"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  administrator_login    = "pgadmin"
  administrator_password = random_password.dd_admin_password.result
  version                = "16"
  sku_name               = "B_Standard_B1ms"
  storage_mb             = 32768
  backup_retention_days  = 35

  authentication {
    password_auth_enabled = true
  }

  high_availability {
    mode = "SameZone"
  }

  public_network_access_enabled = true
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "dd-tt02-pg-db"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# App-bruker
resource "azurerm_postgresql_flexible_server_role" "app_user" {
  name      = "appuser"
  server_id = azurerm_postgresql_flexible_server.pg.id
  password  = random_password.user_password.result
}

# Key Vault-oppsett
data "azurerm_key_vault" "digdir_kv" {
  name                = "digdir-tt02-apps-kv"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_secret" "admin_conn_string" {
  name         = "dd-pgadmin-connection-string"
  value        = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${azurerm_postgresql_flexible_server.pg.administrator_login};Database=${azurerm_postgresql_flexible_server_database.db.name};Port=5432;Password=${random_password.dd_admin_password.result};SSLMode=Prefer"
  key_vault_id = data.azurerm_key_vault.digdir_kv.id
}

resource "azurerm_key_vault_secret" "user_conn_string" {
  name         = "dd-pguser-connection-string"
  value        = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${azurerm_postgresql_flexible_server_role.app_user.name};Database=${azurerm_postgresql_flexible_server_database.db.name};Port=5432;Password=${random_password.dd_user_password.result};SSLMode=Prefer"
  key_vault_id = data.azurerm_key_vault.digdir_kv.id
}
