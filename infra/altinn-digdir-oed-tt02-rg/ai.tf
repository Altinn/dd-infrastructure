resource "azurerm_log_analytics_workspace" "law" {
  name                = "Workspace-altinnapps-digdir-oed-tt02-rg-WEU"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  retention_in_days   = 30
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

import {
  to = azurerm_application_insights.feedpoller
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Insights/components/oed-test-feedpoller-ai"
}

resource "azurerm_application_insights" "feedpoller" {
  name                = "oed-${var.environment}-feedpoller-ai"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  sampling_percentage = 100
  disable_ip_masking  = true
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

resource "azurerm_application_insights" "authz_ai" {
  name                = "oed-${var.environment}-authz-ai"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  sampling_percentage = 100
  disable_ip_masking  = true
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

import {
  to = azurerm_application_insights.testapp_ai
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Insights/components/oed-testapp-ai"
}

resource "azurerm_application_insights" "testapp_ai" {
  name                = "oed-testapp-ai"
  location            = var.alt_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  sampling_percentage = 100
  disable_ip_masking  = true
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}

resource "azurerm_application_insights" "adminapp_ai" {
  name                = "dd-${var.environment}-adminapp-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  sampling_percentage = 100
  disable_ip_masking  = true
  tags = {
    "costcenter" = "altinn3"
    "solution"   = "apps"
  }
}
