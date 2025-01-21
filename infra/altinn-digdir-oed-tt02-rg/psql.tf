resource "azurerm_postgresql_flexible_server" "psql" {
  administrator_login           = "oed${var.environment}pgadmin"
  auto_grow_enabled             = false
  backup_retention_days         = 7
  location                      = var.alt_location
  name                          = "oed-${var.environment}-authz-pg"
  public_network_access_enabled = true
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  version = "14"
  zone    = "1"
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = "cd0026d8-283b-4a55-9bfa-d0ef4a8ba21c"
  }
}
