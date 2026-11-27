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
  depends_on = [local.whitelist_map_pg]
  for_each   = local.whitelist_map_pg

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.pg.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Authz db
# Hent connection string fra Key Vault
# For å feks. oppgrade db versjon, så må en ha admin rettigheter på serveren
ephemeral "random_password" "psql_admin_password" {
  length           = 32
  override_special = "!#%*-_+"
}

# Same as prod: both connection strings use the server admin login.
resource "azurerm_key_vault_secret" "psql_connect" {
  for_each         = toset(["Secrets--PostgreSqlAdminConnectionString", "Secrets--PostgreSqlUserConnectionString"])
  name             = each.key
  value_wo         = "Server=${azurerm_postgresql_flexible_server.psql.fqdn};Username=${azurerm_postgresql_flexible_server.psql.administrator_login};Database=oedauthz;Port=5432;Password=${ephemeral.random_password.psql_admin_password.result};SSLMode=Prefer"
  value_wo_version = var.secret_rotation_version
  key_vault_id     = azurerm_key_vault.kv.id
}

import {
  to = azurerm_key_vault_secret.psql_connect["Secrets--PostgreSqlAdminConnectionString"]
  id = "https://oed-kv.vault.azure.net/secrets/Secrets--PostgreSqlAdminConnectionString/a1fc0662aaf14c0a8c5cb4df9e97fad4"
}

import {
  to = azurerm_key_vault_secret.psql_connect["Secrets--PostgreSqlUserConnectionString"]
  id = "https://oed-kv.vault.azure.net/secrets/Secrets--PostgreSqlUserConnectionString/b7262268bee84449af99389439204fac"
}


resource "azurerm_postgresql_flexible_server" "psql" {
  lifecycle {
    prevent_destroy = true
  }
  administrator_login               = "oed${var.environment}pgadmin"
  administrator_password_wo         = ephemeral.random_password.psql_admin_password.result
  administrator_password_wo_version = var.secret_rotation_version
  auto_grow_enabled                 = false
  backup_retention_days             = 7
  location                          = var.alt_location
  name                              = "oed-${var.environment}-authz-pg"
  public_network_access_enabled     = true
  resource_group_name               = azurerm_resource_group.rg.name
  sku_name                          = "B_Standard_B4ms"
  version                           = "16"
  zone                              = "1"

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

resource "azurerm_postgresql_flexible_server_database" "oedauthz" {
  lifecycle {
    prevent_destroy = true
  }
  name      = "oedauthz"
  server_id = azurerm_postgresql_flexible_server.psql.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "authz_whitelist" {
  depends_on = [local.whitelist_map_pg]
  for_each   = local.whitelist_map_pg

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.psql.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Connection logging with downloadable log files (az postgres flexible-server server-logs),
# used to see which clients connect from which IPs. All three parameters are dynamic (no restart).
locals {
  pg_servers_with_connection_logging = {
    pg   = azurerm_postgresql_flexible_server.pg.id
    psql = azurerm_postgresql_flexible_server.psql.id
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
