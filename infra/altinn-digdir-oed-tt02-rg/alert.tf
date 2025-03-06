resource "azurerm_monitor_action_group" "email_ag" {
  name                = "DD-email-notification-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "E-mail DD"
  email_receiver {
    email_address = var.support_email
    name          = "send-to-EmailAction"
  }
}

## Deceased is alive and instance already exists
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "deadisalive_ar" {
  name                  = "Deceased is alive and instance already exists"
  display_name          = "Deceased is alive and instance already exists"
  description           = "Deceased is alive and instance already exists"
  evaluation_frequency  = "PT30M"
  location              = azurerm_resource_group.rg.location  
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 2  
  window_duration       = "PT30M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 0
    operator                = "GreaterThan"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where Properties.ActionName startswith \"Altinn.App.Controllers.CloudEventController.PostCloudEvent\"\n| where SeverityLevel == 3\n| where Properties.EventId == 5000\n\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## Failed to rachive
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_to_archive_ar" {
  name                  = "Failed to archive"
  display_name          = "Failed to archive"
  description           = "Failed to archive"
  evaluation_frequency  = "PT30M"
  location              = azurerm_resource_group.rg.location  
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 2  
  window_duration       = "PT30M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 0
    operator                = "GreaterThan"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where Properties.ActionName startswith \"Altinn.App.Controllers.CloudEventController.PostCloudEvent\"\n| where SeverityLevel == 3\n| where Properties.EventId == 5002\n\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}
