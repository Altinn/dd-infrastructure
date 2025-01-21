resource "azurerm_resource_group" "rg" {
  location = var.rg_location
  name     = var.rg_name
}
