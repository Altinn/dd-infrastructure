#Azure alerts
resource "azurerm_monitor_action_group" "email_ag" {
  name                = "DD-email-notification-test-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "E-mail DD-T"
  email_receiver {
    email_address = var.support_email
    name          = "send-to-EmailAction"
  }
}

#grafana alerts
# Folder
resource "grafana_folder" "digitalt_dodsbo" {
  provider = grafana.managed
  title    = "Digitalt Dødsbo"
}

# Contact point
resource "grafana_contact_point" "slack_dodsbo" {
  provider = grafana.managed

  name     = "Digitalt Dødsbo"
  slack {
    url = var.slack_webhook_url
    recipient = "#digitalt-dodsbo"
  }
}

# Notification policy with label match
resource "grafana_notification_policy" "system_dd" {
  provider = grafana.managed
  group_by = ["System"]
  contact_point = grafana_contact_point.slack_dodsbo.name
  group_wait     = "10s"
  group_interval = "5m"
  repeat_interval = "1h"
  policy {
    matcher {
      label = "System"
      match = "="
      value = "DD"
    }
  }
}