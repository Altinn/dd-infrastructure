

locals {
  # splitter "outbound_ip_addresses" (komma-separert streng) til liste
  authz_ips      = split(",", azurerm_windows_web_app.authz.outbound_ip_addresses)
  feedpoller_ips = [azurerm_public_ip.pip.ip_address]

  # bygg en liste av objekter med navn og IP
  dynamic_whitelist = flatten([
    [for ip in local.authz_ips : {
      name     = "authz-${replace(ip, ".", "-")}"
      start_ip = ip
      end_ip   = ip
    }],
    [for ip in local.feedpoller_ips : {
      name     = "feedpoller-${replace(ip, ".", "-")}"
      start_ip = ip
      end_ip   = ip
    }],
  ])

  # kombiner statisk + dynamisk
  all_whitelist = concat(var.static_whitelist, local.dynamic_whitelist)

  # lag map for for_each
  whitelist_map_pg = { for rule in local.all_whitelist : rule.name => rule }
}