resource "azurerm_public_ip" "pip" {
  lifecycle {
    ignore_changes = [
      tags["costcenter"],
      tags["solution"]
    ]
  }
  name                 = "oed-feedpoller-ip"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  allocation_method    = "Static"
  ddos_protection_mode = "VirtualNetworkInherited"
  domain_name_label    = "oed-feedpoller"
  ip_version           = "IPv4"
  zones                = ["1", "2", "3"]
}

resource "azurerm_virtual_network" "vnet" {
  name                = "oed-feedpoller-vnet"
  address_space       = ["10.37.167.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
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
  name                = "oed-feedpoller-nat"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.pip.id
}

resource "azurerm_subnet_nat_gateway_association" "nat_subnet" {
  subnet_id      = azurerm_subnet.default.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}
