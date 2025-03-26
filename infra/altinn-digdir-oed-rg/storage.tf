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

resource "random_password" "psql_oedpgadmin" {
  length           = 32
  special          = true
  override_special = "!@#$%&*"
}

resource "azurerm_postgresql_flexible_server" "psql" {
  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
  administrator_login           = "oedpgadmin"
  administrator_password        = random_password.psql_oedpgadmin.result
  auto_grow_enabled             = true
  backup_retention_days         = 35
  location                      = azurerm_resource_group.rg.location
  name                          = "oed-authz-pg"
  public_network_access_enabled = true
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = "B_Standard_B1ms"
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

resource "azurerm_key_vault_secret" "psql_connect" {
  for_each     = toset(["Secrets--PostgreSqlAdminConnectionString", "Secrets--PostgreSqlUserConnectionString"])
  name         = each.key
  value        = "Server=${azurerm_postgresql_flexible_server.psql.fqdn};Username=${azurerm_postgresql_flexible_server.psql.administrator_login};Database=oedauthz;Port=5432;Password=${random_password.psql_oedpgadmin.result};SSLMode=Prefer"
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_redis_cache" "cache" {
  name                = "oed-cache"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
}
