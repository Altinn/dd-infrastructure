resource "azurerm_servicebus_namespace" "dd_sb_ns" {
  name                = "dd-${var.environment}-sbn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
  network_rule_set {
    default_action                = "Deny"
    public_network_access_enabled = true
    trusted_services_allowed      = true
    ip_rules                      = local.whitelist_array
  }
}

# Gi full topic/subscription access til authz
resource "azurerm_role_assignment" "sb_authz_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_linux_web_app.authz_linux.identity[0].principal_id
}

# Gi full topic/subscription access til feedpoller function app
resource "azurerm_role_assignment" "sb_feedpoller_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_windows_function_app.feedpoller.identity[0].principal_id
}

data "azuread_application" "kv_sp" {
  display_name = var.a3_sp_app_name
}

data "azuread_service_principal" "aks_sp" {
  client_id = data.azuread_application.kv_sp.client_id
}

resource "azurerm_role_assignment" "sb_aks_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_service_principal.aks_sp.object_id
}