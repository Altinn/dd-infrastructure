resource "azurerm_public_ip" "pip" {
  allocation_method       = "Static"
  ddos_protection_mode    = "VirtualNetworkInherited"
  ddos_protection_plan_id = null
  domain_name_label       = "oed-${var.environment}-feedpoller"
  edge_zone               = null
  idle_timeout_in_minutes = 4
  ip_tags                 = {}
  ip_version              = "IPv4"
  location                = var.alt_location
  name                    = "oed-${var.environment}-feedpoller-ip"
  public_ip_prefix_id     = null
  resource_group_name     = azurerm_resource_group.rg.name
  reverse_fqdn            = null
  sku                     = "Standard"
  sku_tier                = "Regional"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  zones = []
}
