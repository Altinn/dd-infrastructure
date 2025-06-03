resource "azurerm_log_analytics_workspace" "law" {
  name                = "altinn-digdir-oed-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
}

resource "azurerm_application_insights" "feedpoller" {
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

resource "azurerm_application_insights" "adminapp_ai" {
  name                = "dd-${var.environment}-adminapp-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  sampling_percentage = 100
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}