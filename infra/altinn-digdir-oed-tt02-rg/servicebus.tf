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

data "azuread_service_principal" "aks_identity" {
  client_id = var.digdir_kv_sp_object_id
}

# Gi full topic/subscription access til felles principal fra AKS
resource "azurerm_role_assignment" "sb_aks_principal_ra" {
  depends_on = [azuread_service_principal.aks_identity]
  scope                = azurerm_servicebus_namespace.dd_sb_ns.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azuread_service_principal.aks_sp.object_id
}