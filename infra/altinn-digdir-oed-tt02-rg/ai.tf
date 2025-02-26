resource "azurerm_log_analytics_workspace" "law" {
  name                = "altinn-digdir-oed-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}

resource "azurerm_application_insights" "feedpoller_ai" {
  name                = "oed-feedpoller-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

resource "azurerm_application_insights" "authz_ai" {
  name                = "oed-authz-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}

import {
  to = azurerm_application_insights.testapp_ai
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/components/oed-testapp-ai"
}

resource "azurerm_application_insights" "testapp_ai" {
  name                = "oed-testapp-ai"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
}
