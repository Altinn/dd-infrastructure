# PostgreSQL for OED
# Passwords are ephemeral and only reach write-only arguments, so they never land in state or plan.
# They are applied when var.secret_rotation_version changes.
ephemeral "random_password" "dd_admin_password" {
  length           = 32
  override_special = "!#%*-_+"
}

ephemeral "random_password" "dd_user_password" {
  length           = 32
  override_special = "!#%*-_+"
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
  administrator_login               = "pgadmin"
  administrator_password_wo         = ephemeral.random_password.dd_admin_password.result
  administrator_password_wo_version = var.secret_rotation_version
  version                           = "16"
  sku_name                      = "GP_Standard_D2s_v3"
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
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "max_connections" {
  name      = "max_connections"
  server_id = azurerm_postgresql_flexible_server.pg.id
  value     = "859"
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

#Har ikke tilgang til a3 aps kv, så connstringen legges i oed-kv og må flyttes manuelt
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

# PostgreSQL for OED Authz
ephemeral "random_password" "psql_admin_password" {
  length           = 32
  override_special = "!#%*-_+"
}

resource "azurerm_postgresql_flexible_server" "psql" {
  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
    prevent_destroy = true
  }
  administrator_login               = "oedpgadmin"
  administrator_password_wo         = ephemeral.random_password.psql_admin_password.result
  administrator_password_wo_version = var.secret_rotation_version
  auto_grow_enabled                 = true
  backup_retention_days         = 35
  location                      = azurerm_resource_group.rg.location
  name                          = "oed-authz-pg"
  public_network_access_enabled = true
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = "GP_Standard_D2s_v3"
  version                       = "16"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
  }

  maintenance_window {
    day_of_week  = "2"
    start_hour   = "1"
    start_minute = "4"
  }
}

resource "azurerm_postgresql_flexible_server_database" "oedauthz" {
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

resource "azurerm_key_vault_secret" "psql_connect" {
  for_each         = toset(["Secrets--PostgreSqlAdminConnectionString", "Secrets--PostgreSqlUserConnectionString"])
  name             = each.key
  value_wo         = "Server=${azurerm_postgresql_flexible_server.psql.fqdn};Username=${azurerm_postgresql_flexible_server.psql.administrator_login};Database=oedauthz;Port=5432;Password=${ephemeral.random_password.psql_admin_password.result};SSLMode=Prefer"
  value_wo_version = var.secret_rotation_version
  key_vault_id     = azurerm_key_vault.kv.id
}