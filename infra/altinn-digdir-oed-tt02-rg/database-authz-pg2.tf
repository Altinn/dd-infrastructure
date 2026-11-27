# Replacement for oed-test-authz-pg, which cannot have a private endpoint (PrivateEndpointFeatureNotSupportedOnServer;
# a point-in-time restore inherits the limitation). Created empty next to the old server; the data is copied with
# pg_dump/pg_restore, then the apps are pointed at it through the secret below. The old server is retired afterwards.
ephemeral "random_password" "psql2_admin_password" {
  length           = 32
  override_special = "!#%*-_+"
}

resource "azurerm_postgresql_flexible_server" "psql2" {
  lifecycle {
    prevent_destroy = true
  }
  administrator_login               = "oed${var.environment}pgadmin"
  administrator_password_wo         = ephemeral.random_password.psql2_admin_password.result
  administrator_password_wo_version = var.secret_rotation_version
  auto_grow_enabled                 = false
  backup_retention_days             = 7
  location                          = var.alt_location
  name                              = "oed-${var.environment}-authz-pg2"
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

resource "azurerm_postgresql_flexible_server_database" "oedauthz2" {
  lifecycle {
    prevent_destroy = true
  }
  name      = "oedauthz"
  server_id = azurerm_postgresql_flexible_server.psql2.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "authz2_whitelist" {
  for_each = local.authz_pg_whitelist_map

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.psql2.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Written in the same apply as the server's password, which is ephemeral and not stored anywhere else.
# The apps switch to this secret in a later change; until then nothing reads it.
resource "azurerm_key_vault_secret" "psql2_connect" {
  name             = "AuthzPg2--ConnectionString"
  value_wo         = "Server=${azurerm_postgresql_flexible_server.psql2.fqdn};Username=${azurerm_postgresql_flexible_server.psql2.administrator_login};Database=${azurerm_postgresql_flexible_server_database.oedauthz2.name};Port=5432;Password=${ephemeral.random_password.psql2_admin_password.result};SSLMode=Prefer"
  value_wo_version = var.secret_rotation_version
  key_vault_id     = azurerm_key_vault.kv.id
}
