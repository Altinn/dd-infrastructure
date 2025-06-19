import {
  to = azurerm_linux_web_app.easyauth_app
  id = "/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/Microsoft.Web/sites/dd-test-easyauth-app"
}

resource "azurerm_linux_web_app" "easyauth_app" {
  name                = "dd-${var.environment}-easyauth-app"
  service_plan_id     = azurerm_service_plan.admin_asp.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  https_only          = true
  site_config {
    always_on = true
    application_stack {
      dotnet_version = "8.0"
    }
  }
  identity {
    type = "SystemAssigned"
  }
}