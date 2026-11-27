# PostgreSQL for OED
# Passwords are ephemeral and only reach write-only arguments, so they never land in state or plan.
# They are applied when var.secret_rotation_version changes.
# If an apply that bumps it fails partway, do not re-run it: each run generates new passwords, and
# resources already at the new version are skipped, so servers and connection strings would differ.
# Bump var.secret_rotation_version again, apply, then run PostApply.
ephemeral "random_password" "dd_admin_password" {
  length           = 32
  override_special = "!#%*-_+"
}

ephemeral "random_password" "dd_user_password" {
  length           = 32
  override_special = "!#%*-_+"
}

resource "azurerm_postgresql_flexible_server" "pg" {
  name                              = "dd-${var.environment}-pg"
  location                          = azurerm_resource_group.rg.location
  resource_group_name               = azurerm_resource_group.rg.name
  administrator_login               = "pgadmin"
  administrator_password_wo         = ephemeral.random_password.dd_admin_password.result
  administrator_password_wo_version = var.secret_rotation_version
  version                           = "16"
  sku_name                          = "B_Standard_B2ms"
  storage_mb                        = 32768
  backup_retention_days             = 7
  auto_grow_enabled                 = false
  public_network_access_enabled     = true
  zone                              = "1"

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

resource "azurerm_postgresql_flexible_server_database" "oed_db" {
  name      = "dd-oed-${var.environment}-pg-db"
  server_id = azurerm_postgresql_flexible_server.pg.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

locals {
  app_user_name = "appuser"
}

# Admin connection string for the OED database.
resource "azurerm_key_vault_secret" "admin_conn_string" {
  name             = "dd-pgadmin-connection-string"
  value_wo         = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${azurerm_postgresql_flexible_server.pg.administrator_login};Database=${azurerm_postgresql_flexible_server_database.oed_db.name};Port=5432;Password='${ephemeral.random_password.dd_admin_password.result}';SSLMode=Prefer"
  value_wo_version = var.secret_rotation_version
  key_vault_id     = azurerm_key_vault.kv.id
}

# The appuser role password is not managed by Terraform: after an apply that bumps
# var.secret_rotation_version, set it with ALTER ROLE from this secret (runbook PostApply).
resource "azurerm_key_vault_secret" "user_conn_string" {
  name             = "OedConfig--Postgres--ConnectionString"
  value_wo         = "Server=${azurerm_postgresql_flexible_server.pg.fqdn};Username=${local.app_user_name};Database=${azurerm_postgresql_flexible_server_database.oed_db.name};Port=5432;Password='${ephemeral.random_password.dd_user_password.result}';SSLMode=Prefer"
  value_wo_version = var.secret_rotation_version
  key_vault_id     = azurerm_key_vault.kv.id
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "whitelist" {
  for_each = local.dd_pg_whitelist_map

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# The tt02 authz database is on oed-test-authz-pg2 (database-authz-pg2.tf). The old oed-test-authz-pg was
# retired: it could not have a private endpoint.

# Connection logging with downloadable log files (az postgres flexible-server server-logs),
# used to see which clients connect from which IPs. All three parameters are dynamic (no restart).
locals {
  pg_servers_with_connection_logging = {
    pg    = azurerm_postgresql_flexible_server.pg.id
    psql2 = azurerm_postgresql_flexible_server.psql2.id
  }
  pg_connection_logging_parameters = {
    "log_connections"          = "on"
    "logfiles.download_enable" = "on"
    "logfiles.retention_days"  = "7"
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "connection_logging" {
  for_each = {
    for pair in setproduct(keys(local.pg_servers_with_connection_logging), keys(local.pg_connection_logging_parameters)) :
    "${pair[0]}/${pair[1]}" => {
      server_id = local.pg_servers_with_connection_logging[pair[0]]
      name      = pair[1]
      value     = local.pg_connection_logging_parameters[pair[1]]
    }
  }

  name      = each.value.name
  server_id = each.value.server_id
  value     = each.value.value
}
