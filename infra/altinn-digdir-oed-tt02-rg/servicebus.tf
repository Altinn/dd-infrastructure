resource "azurerm_servicebus_namespace" "dd_sb_ns" {
  name                = "dd-${var.environment}-sbn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags = {
    costcenter = "altinn3"
    solution   = "apps"
  }
}

resource "azurerm_servicebus_namespace_network_rule_set" "sb_whitelist" {
  name                = azurerm_servicebus_namespace.dd_sb_ns.name
  namespace_name      = azurerm_servicebus_namespace.dd_sb_ns.name
  resource_group_name = azurerm_servicebus_namespace.dd_sb_ns.resource_group_name

  default_action                = "Deny"
  public_network_access_enabled = true
  trusted_services_allowed      = true
  ip_rules                      = whitelist_array
}

# Gi full topic/subscription access til testapp
resource "azurerm_role_assignment" "sb_testapp_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_windows_web_app.testapp.identity[0].principal_id
}

# Gi full topic/subscription access til authz
resource "azurerm_role_assignment" "sb_authz_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_windows_web_app.authz.identity[0].principal_id
}

# Gi full topic/subscription access til feedpoller function app
resource "azurerm_role_assignment" "sb_feedpoller_ra" {
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_windows_function_app.feedpoller.identity[0].principal_id
}