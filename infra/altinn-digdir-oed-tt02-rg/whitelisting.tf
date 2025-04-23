locals {
  # 👉 Legg inn dine CIDR-blokker her
  allowed_cidrs = [
    var.aks_cdir
  ]

  # 🚦 Skiller mellom CIDR og enkel IP (de uten "/")
  individual_ips = [
    for ip in local.allowed_cidrs : ip
    if !can(regex("/", ip))
  ]

  cidr_blocks = [
    for cidr in local.allowed_cidrs : cidr
    if can(regex("/", cidr))
  ]

  # 🔁 Utvider hver CIDR til en liste med alle IP-er i blokken
  cidr_ips = flatten([
    for cidr in local.cidr_blocks : [
      for i in range(pow(2, 32 - tonumber(split("/", cidr)[1]))) :
      cidrhost(cidr, i)
    ]
  ])

  # 📦 Full liste over alle individuelle AKS IP-er
  whitelist_array = concat(local.individual_ips, local.cidr_ips)

  whitelist_feedpoller_pip = azurerm_public_ip.pip.ip_address
  whitelist_authz_comma    = split(",", azurerm_windows_web_app.authz.outbound_ip_addresses)
  whitelist_authz_array    = toset(split(",", azurerm_windows_web_app.authz.outbound_ip_addresses))

  whitelist_all_comma = concat(split(",", local.whitelist_array), split(",", local.whitelist_authz_array), local.whitelist_feedpoller_pip)
  whitelist_all_array = concat(split(",", locals.whitelist_authz_comma), local.whitelist_feedpoller_pip, local.whitelist_array)

  whitelist_start_stop = merge(
    {
      for cidr in local.allowed_cidrs :
      replace(replace(cidr, ".", "_"), "/", "_") => {
        start = cidrhost(cidr, 0)
        end   = cidrhost(cidr, pow(2, 32 - tonumber(split("/", cidr)[1])) - 1)
      }
    },
    {
      for ip in whitelist_authz_array :
      replace(ip, ".", "_") => {
        start = ip
        end   = ip
      }
    }
  )
}