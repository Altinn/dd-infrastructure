import {
  to = azurerm_public_ip.pip
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Network/publicIPAddresses/oed-test-feedpoller-ip"
}

resource "azurerm_public_ip" "pip" {
  lifecycle {
    ignore_changes = [
      tags["costcenter"],
      tags["solution"]
    ]
  }
  name                 = "oed-${var.environment}-feedpoller-ip"
  location             = var.alt_location
  resource_group_name  = azurerm_resource_group.rg.name
  allocation_method    = "Static"
  ddos_protection_mode = "VirtualNetworkInherited"
  domain_name_label    = "oed-${var.environment}-feedpoller"
  ip_version           = "IPv4"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "oed-${var.environment}-feedpoller-vnet"
  address_space       = ["10.37.167.0/24"]
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

resource "azurerm_subnet" "default" {
  address_prefixes     = ["10.37.167.0/27"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_nat_gateway" "nat" {
  name                = "oed-${var.environment}-feedpoller-nat"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
}

#import {
#  to = azurerm_nat_gateway_public_ip_association.nat_pip
#  id = "${azurerm_nat_gateway.nat.id},${azurerm_public_ip.pip.id}"
#}

#resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
#  nat_gateway_id       = azurerm_nat_gateway.nat.id
#  public_ip_address_id = azurerm_public_ip.pip.id
#}

# Subnets for private Postgres access: the admin and authz apps join the VNet next to the feedpoller,
# and the Postgres private endpoints get their own subnet. One subnet per App Service plan.
locals {
  app_subnets = {
    admin = "10.37.167.32/27"
    authz = "10.37.167.64/27"
  }
}

resource "azurerm_subnet" "app" {
  for_each = local.app_subnets

  address_prefixes     = [each.value]
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  delegation {
    name = "delegation"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.Web/serverFarms"
    }
  }
}

# The apps' internet traffic leaves through the feedpoller's NAT gateway, so all three share one outbound IP.
resource "azurerm_subnet_nat_gateway_association" "app" {
  for_each = azurerm_subnet.app

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet" "private_endpoints" {
  address_prefixes     = ["10.37.167.96/27"]
  name                 = "snet-pe"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}
