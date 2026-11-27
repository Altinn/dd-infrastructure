# Private access to Postgres for the apps in the VNet (admin, authz, feedpoller). Inside the VNet the servers'
# names resolve to the private endpoints through this zone; outside it, public DNS and the firewall rules still apply.
locals {
  private_endpoint_tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.private_endpoint_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                = "${azurerm_virtual_network.vnet.name}-link"
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  virtual_network_id  = azurerm_virtual_network.vnet.id
  tags                = local.private_endpoint_tags
}

# On oed-test-authz-pg2: the old oed-test-authz-pg cannot have a private endpoint.
resource "azurerm_private_endpoint" "authz_pg" {
  name                = "pe-${azurerm_postgresql_flexible_server.psql2.name}"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id
  tags                = local.private_endpoint_tags

  private_service_connection {
    name                           = "${azurerm_postgresql_flexible_server.psql2.name}-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.psql2.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  # A fixed address, so it never changes under clients that pin it (e.g. a developer's hosts file).
  ip_configuration {
    name               = "${azurerm_postgresql_flexible_server.psql2.name}-ip"
    private_ip_address = "10.37.167.100"
    subresource_name   = "postgresqlServer"
    member_name        = "postgresqlServer"
  }

  private_dns_zone_group {
    name                 = "postgres"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }
}
