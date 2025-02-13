resource "azurerm_storage_account" "sa" {
  account_kind             = "Storage"
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = var.alt_location
  name                     = "oed${var.environment}feedpollerstrg"
  resource_group_name      = azurerm_resource_group.rg.name
  tags = {
    costcenter = "altinn3"
    service    = "oed"
    solution   = "apps"
  }
}
