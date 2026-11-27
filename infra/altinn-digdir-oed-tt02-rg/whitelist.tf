locals {
  # The apps reach both databases through their private endpoints, so the firewall rules only cover clients
  # outside the VNet: developers, and the oed Studio app in Altinn's cluster (dd database only).
  dd_pg_whitelist_map    = { for rule in var.static_whitelist : rule.name => rule }
  authz_pg_whitelist_map = { for rule in var.static_whitelist : rule.name => rule if !rule.dd_only }

  # eks. ["10.0.0.1","10.0.0.2",.....]
  # Ranges are expanded to every address in them, since Service Bus ip_rules
  # takes single IPs or CIDRs, not start/end ranges. A range must stay within
  # one /24 (checked by the validation on var.static_whitelist).
  whitelist_array = distinct(flatten([
    for rule in var.static_whitelist : [
      for i in range(
        tonumber(split(".", rule.start_ip)[3]),
        tonumber(split(".", rule.end_ip)[3]) + 1
      ) : format("%s.%d", join(".", slice(split(".", rule.start_ip), 0, 3)), i)
    ]
  ]))
}

output "whitelist_ips" {
  description = "Alle IP-adresser som blir whitelistet (inkludert end_ip hvis forskjellig)"
  value       = local.whitelist_array
}