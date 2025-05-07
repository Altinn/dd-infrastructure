resource "azurerm_monitor_action_group" "email_ag" {
  name                = "DD-email-notification-prod-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "E-mail DD-p"
  email_receiver {
    email_address = var.support_email
    name          = "send-to-EmailAction"
  }
}