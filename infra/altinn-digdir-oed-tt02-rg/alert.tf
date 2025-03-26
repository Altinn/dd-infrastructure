resource "azurerm_monitor_action_group" "email_ag" {
  name                = "DD-email-notification-test-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "E-mail DD - test"
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
  evaluation_frequency  = "PT5M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 1
  window_duration       = "PT5M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where Properties.EventId == 5000\n\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## Sensitiv adresse kode 4, 6 eller 7
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "SensitiveHeir_ar" {
  name                  = "Sensitive heir address code 4,6 or 7"
  display_name          = "Sensitive heir address code 4,6 or 7"
  description           = "Sensitive heir address code 4,6 or 7"
  evaluation_frequency  = "PT5M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 1
  window_duration       = "PT5M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where Properties.EventId == 5002\n\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## Arkivering har feilet
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_to_archive_ar" {
  name                  = "Archiving has failed"
  display_name          = "Archiving has failed"
  description           = "Archiving has failed"
  evaluation_frequency  = "PT5M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 1
  window_duration       = "PT5M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| where Message startswith \"Failed to archive\" or Properties.EventId == 4004\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## En av arvingene er mindreårig
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "minor_heir_ar" {
  name                  = "One or more heirs are minors"
  display_name          = "One or more heirs are minors"
  description           = "One or more heirs are minors"
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
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| Properties.EventId == 3000\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}
## Bo er feilført fra DA
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "misposted_ar" {
  name                  = "The estate is misposted from DA"
  display_name          = "The estate is misposted from DA"
  description           = "The estate is misposted from DA"
  evaluation_frequency  = "PT30M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 3
  window_duration       = "PT30M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| Properties.EventId == 2002\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## Partyservice har feilet
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "partyservice_failed_ar" {
  name                  = "Partyservice has failed"
  display_name          = "Partyservice has failed"
  description           = "Partyservice has failed"
  evaluation_frequency  = "PT15M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 0
  window_duration       = "PT15M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| Properties.EventId == 4005\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}

## FReg har feilet
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "freg_failed_ar" {
  name                  = "FReg has failed"
  display_name          = "FReg has failed"
  description           = "FReg has failed"
  evaluation_frequency  = "PT15M"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  scopes                = [digdir_altinn3_law_id]
  target_resource_types = ["Microsoft.OperationalInsights/workspaces"]
  severity              = 0
  window_duration       = "PT15M"
  action {
    action_groups = [azurerm_monitor_action_group.email_ag.id]
  }
  criteria {
    threshold = 1
    operator                = "GreaterThanOrEqual"
    query                   = "AppTraces\n| where AppRoleName startswith \"oed\"\n| Properties.EventId == 4005\n"
    time_aggregation_method = "Count"
    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }
}