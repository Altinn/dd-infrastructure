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

# er dette rett??
import{
  to = azurerm_nat_gateway_public_ip_association.nat_pip
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Network/virtualNetworks/oed-test-feedpoller-vnet/subnets/default/providers/Microsoft.Network/natGateways/oed-test-feedpoller-nat"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.pip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_subnet" {
  subnet_id      = azurerm_subnet.default.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
