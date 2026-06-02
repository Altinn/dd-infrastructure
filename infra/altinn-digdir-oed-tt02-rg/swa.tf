resource "azurerm_static_web_app" "qaswa" {
  name                 = "oed-qa-swa"
  resource_group_name  = azurerm_resource_group.rg.name
  location              = var.alt_location
}