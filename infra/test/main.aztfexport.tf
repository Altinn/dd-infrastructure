# Should be deleted? The file is still here because its a resource that was imported into terraform
# Should atleast change the email address to the another one
resource "azurerm_monitor_action_group" "res-0" {
  name                = "DD-email-notification-ag"
  resource_group_name = "altinn-digdir-oed-tt02-rg"
  short_name          = "E-mail DD"
  email_receiver {
    email_address = "kurt.monge@digdir.no"
    name          = "send-to-tl_-EmailAction-"
  }
}
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "res-1" {
  display_name          = "Deceased is alive and instance already exists_v2"
  evaluation_frequency  = "PT5M"
  location              = "norwayeast"
  name                  = "Deceased is alive and instance already exists_v2"
  resource_group_name   = "altinn-digdir-oed-tt02-rg"
  scopes                = ["/subscriptions/7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103/resourceGroups/monitor-digdir-tt02-rg/providers/Microsoft.OperationalInsights/workspaces/application-digdir-tt02-law"]
  severity              = 2
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  window_duration       = "PT5M"
  action {
    action_groups = ["/subscriptions/7B6F8F15-3A3E-43A2-B6AC-8EB6C06AD103/resourceGroups/altinn-digdir-oed-tt02-rg/providers/microsoft.insights/actionGroups/DD-email-notification-ag"]
  }

  criteria {
    operator                = "GreaterThan"
    threshold               = 0
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where SeverityLevel == 3\n| where Properties.EventId == 4003\n\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}
