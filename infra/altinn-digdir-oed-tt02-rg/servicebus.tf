resource "azurerm_servicebus_namespace" "dd_sb_ns" {
  name                = "dd-${var.environment}-sbn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  minimum_tls_version = "1.3"
  
   tags = {
    costcenter = "altinn3"
    solution   = "apps"
  } 
}

resource "azurerm_servicebus_topic" "dd_events" {
  name         = "dd-events"
  namespace_id = azurerm_servicebus_namespace.dd_sb_ns.id
}

locals {
  subscriptions = [
    {
      name             = "admin-sub"
      sql_filter       = "type = 'admin.ui'"
      requires_session = false
    },
    {
      name             = "authz-sub"
      sql_filter       = "type LIKE 'authz.%'"
      requires_session = true
    },
    {
      name             = "feedpoller-sub"
      sql_filter       = "type = 'feed.update'"
      requires_session = false
    },
    {
      name             = "declaration-sub"
      sql_filter       = "type LIKE 'declaration.%'"
      requires_session = true
    },
    {
      name             = "events-sub"
      sql_filter       = "type LIKE 'events.%'"
      requires_session = false
    },
    {
      name             = "oed-sub"
      sql_filter       = "type LIKE 'oed.%'"
      requires_session = true
    }
  ]
}

resource "azurerm_servicebus_subscription" "subs" {
  for_each         = { for sub in local.subscriptions : sub.name => sub }
  name             = each.value.name
  topic_id         = azurerm_servicebus_topic.dd_events.id
  requires_session = each.value.requires_session
  max_delivery_count = 10
  dead_lettering_on_message_expiration = true
}

resource "azurerm_servicebus_subscription_rule" "filters" {
  for_each        = { for sub in local.subscriptions : sub.name => sub }
  name            = "filter-${each.value.name}"
  subscription_id = azurerm_servicebus_subscription.subs[each.key].id
  filter_type     = "SqlFilter"
  sql_filter      = each.value.sql_filter
}

variable "sender_principal_ids" {
  description = "Liste over principal_ids som skal ha sender-rolle."
  type        = list(string)
}