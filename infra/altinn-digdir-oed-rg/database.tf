resource "random_password" "dd_admin_password" {
  length  = 16
  special = true
}

resource "random_password" "dd_user_password" {
  length  = 16
  special = true
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                          = "dd-${var.environment}-pg"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  administrator_login           = "pgadmin"
  administrator_password        = random_password.dd_admin_password.result
  version                       = "16"
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  backup_retention_days         = 35
  auto_grow_enabled             = true
  public_network_access_enabled = true

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = var.tenant_id
  }
  maintenance_window {
    day_of_week  = "2"
    start_hour   = "1"
    start_minute = "4"
  }
}

resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = "dd-${var.environment}-pg-db"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

locals {
  app_user = {
    name     = "appuser"
    password = random_password.dd_user_password.result
  }
}

resource "null_resource" "execute_az_cli" {
  provisioner "local-exec" {
    command = <<-EOT
      az postgres flexible-server connect -n ${azurerm_postgresql_flexible_server.pg.name} -u ${azurerm_postgresql_flexible_server.pg.administrator_login} -p ${random_password.dd_admin_password.result} -d azurerm_postgresql_flexible_server_database.db.name
      pwsh -Command "\$sqlCommand = \"CREATE USER ${local.app_user.name} WITH PASSWORD '${local.app_user.password}'\"; az postgres flexible-server execute -n ${azurerm_postgresql_flexible_server.pg.name} -u ${azurerm_postgresql_flexible_server.pg.administrator_login} -p '${random_password.dd_admin_password}' -d '${azurerm_postgresql_flexible_server_database.db.name}' -q \$sqlCommand --output table"
    EOT
  }
  depends_on = [azurerm_postgresql_flexible_server.pg, azurerm_postgresql_flexible_server_database.db]
}

# Key Vault-oppsett
#data "azurerm_key_vault" "digdir_kv" {
#  name                = var.altinn_apps_digdir_kv_name
#  resource_group_name = var.altinn_apps_digdir_rg_name
#}

#Har ikke tilgang til a3 aps kv, så connstringen legges i oed-kv og må flyttes manuelt
resource "azurerm_key_vault_secret" "admin_conn_string" {
  name  = "dd-pgadmin-connection-string"
  value = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${azurerm_postgresql_flexible_server.pg.administrator_login};Database=${azurerm_postgresql_flexible_server_database.db.name};Port=5432;Password=${random_password.dd_admin_password.result};SSLMode=Prefer"
  #key_vault_id = data.azurerm_key_vault.digdir_kv.id
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "user_conn_string" {
  name  = "dd-pguser-connection-string"
  value = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${local.app_user.name};Database=${azurerm_postgresql_flexible_server_database.db.name};Port=5432;Password=${local.app_user.password};SSLMode=Prefer"
  #key_vault_id = data.azurerm_key_vault.digdir_kv.id
  key_vault_id = azurerm_key_vault.kv.id
}