# Audit logs record publishing-credential (FTP/SCM) sign-ins to the app services.
resource "azurerm_monitor_diagnostic_setting" "app_service_audit_logs" {
  for_each = {
    admin      = azurerm_linux_web_app.admin_app.id
    authz      = azurerm_linux_web_app.authz_linux.id
    feedpoller = azurerm_windows_function_app.feedpoller.id
    testapp    = azurerm_linux_web_app.testapp-linux.id
  }

  name                       = "app-service-audit-logs"
  target_resource_id         = each.value
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AppServiceAuditLogs"
  }
}
