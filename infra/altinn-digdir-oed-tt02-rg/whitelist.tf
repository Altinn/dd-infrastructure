locals {
  admin_ips      = split(",", azurerm_linux_web_app.admin_app.outbound_ip_addresses)
  feedpoller_ips = [azurerm_public_ip.pip.ip_address]

  # bygg en liste av objekter med navn og IP
  dynamic_non_authz_whitelist = flatten([
    [for ip in local.feedpoller_ips : {
      name     = "feedpoller-${replace(ip, ".", "-")}"
      start_ip = ip
      end_ip   = ip
    }],
    [for ip in local.admin_ips : {
      name     = "admin-${replace(ip, ".", "-")}"
      start_ip = ip
      end_ip   = ip
    }]
  ])

  all_non_authz_whitelist = concat(var.static_whitelist, local.dynamic_non_authz_whitelist)

  whitelist_non_authz_array = flatten([
    for rule in local.all_non_authz_whitelist : (
      rule.start_ip != rule.end_ip && rule.end_ip != null ?
      [rule.start_ip, rule.end_ip] :
      [rule.start_ip]
    )
  ])

  authz_ips = split(",", azurerm_windows_web_app.authz.outbound_ip_addresses)

  dynamic_authz_whitelist = flatten([
    [for ip in local.feedpoller_ips : {
      name     = "feedpoller-${replace(ip, ".", "-")}"
      start_ip = ip
      end_ip   = ip
    }]
  ])

  # kombiner statisk + dynamisk
  all_whitelist = concat(var.static_whitelist, local.dynamic_non_authz_whitelist, local.dynamic_authz_whitelist)

  # lag map for for_each
  whitelist_map_pg = { for rule in local.all_whitelist : rule.name => rule }

  # eks. ["10.0.0.1","10.0.0.1",.....]
  whitelist_array = flatten([
    for rule in local.all_whitelist : (
      rule.start_ip != rule.end_ip && rule.end_ip != null ?
      [rule.start_ip, rule.end_ip] :
      [rule.start_ip]
    )
  ])
}

output "whitelist_ips" {
  description = "Alle IP-adresser som blir whitelistet (inkludert end_ip hvis forskjellig)"
  value       = local.whitelist_array
}