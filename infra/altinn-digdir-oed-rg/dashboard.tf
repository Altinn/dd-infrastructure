resource "azurerm_portal_dashboard" "dashboards" {
  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            metadata = {
              asset = {
                idInputName = "id"
                type        = "ApplicationInsights"
              }
              defaultMenuItemId = "overview"
              inputs = [{
                name  = "id"
                value = azurerm_application_insights.authz_ai.id
                }, {
                name  = "Version"
                value = "1.0"
              }]
              type = "Extension/AppInsightsExtension/PartType/AspNetOverviewPinnedPart"
            }
            position = {
              colSpan = 2
              rowSpan = 1
              x       = 0
              y       = 0
            }
          }
          "1" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              defaultMenuItemId = "ProactiveDetection"
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name  = "Version"
                value = "1.0"
              }]
              type = "Extension/AppInsightsExtension/PartType/ProactiveDetectionAsyncPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 2
              y       = 0
            }
          }
          "10" = {
            metadata = {
              asset = {
                idInputName = "ResourceId"
                type        = "ApplicationInsights"
              }
              defaultMenuItemId = "performance"
              inputs = [{
                name  = "ResourceId"
                value = azurerm_application_insights.authz_ai.id
                }, {
                isOptional = true
                name       = "DataModel"
                value = {
                  timeContext = {
                    createdTime           = "2018-05-04T23:43:37.804Z"
                    durationMs            = 86400000
                    grain                 = 1
                    isInitialTime         = false
                    useDashboardTimeRange = false
                  }
                  version = "1.0.0"
                }
                }, {
                isOptional = true
                name       = "ConfigurationId"
                value      = "2a8ede4f-2bee-4b9c-aed9-2db0e8a01865"
              }]
              isAdapter = true
              type      = "Extension/AppInsightsExtension/PartType/CuratedBladePerformancePinnedPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 11
              y       = 1
            }
          }
          "11" = {
            metadata = {
              inputs = []
              settings = {
                content = {
                  settings = {
                    content  = "# Browser"
                    subtitle = ""
                    title    = ""
                  }
                }
              }
              type = "Extension[azure]/HubsExtension/PartType/MarkdownPart"
            }
            position = {
              colSpan = 3
              rowSpan = 1
              x       = 12
              y       = 1
            }
          }
          "12" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              defaultMenuItemId = "browser"
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name  = "MetricsExplorerJsonDefinitionId"
                value = "BrowserPerformanceTimelineMetrics"
                }, {
                name = "TimeContext"
                value = {
                  createdTime           = "2018-05-08T12:16:27.534Z"
                  durationMs            = 86400000
                  grain                 = 1
                  isInitialTime         = false
                  useDashboardTimeRange = false
                }
                }, {
                name = "CurrentFilter"
                value = {
                  eventTypes   = [4, 1, 3, 5, 2, 6, 13]
                  isPermissive = false
                  typeFacets   = {}
                }
                }, {
                name = "id"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name  = "Version"
                value = "1.0"
              }]
              type = "Extension/AppInsightsExtension/PartType/MetricsExplorerBladePinnedPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 15
              y       = 1
            }
          }
          "13" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 5
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Sessions"
                      }
                      name      = "sessions/count"
                      namespace = "microsoft.insights/components/kusto"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 5
                      metricVisualization = {
                        color       = "#7E58FF"
                        displayName = "Users"
                      }
                      name      = "users/count"
                      namespace = "microsoft.insights/components/kusto"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    openBladeOnClick = {
                      destinationBlade = {
                        bladeName     = "ResourceMenuBlade"
                        extensionName = "HubsExtension"
                        parameters = {
                          id     = azurerm_application_insights.authz_ai.id
                          menuid = "segmentationUsers"
                        }
                      }
                      openBlade = true
                    }
                    title = "Unique sessions and users"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 0
              y       = 2
            }
          }
          "14" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 7
                      metricVisualization = {
                        color       = "#EC008C"
                        displayName = "Failed requests"
                      }
                      name      = "requests/failed"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    openBladeOnClick = {
                      destinationBlade = {
                        bladeName     = "ResourceMenuBlade"
                        extensionName = "HubsExtension"
                        parameters = {
                          id     = azurerm_application_insights.authz_ai.id
                          menuid = "failures"
                        }
                      }
                      openBlade = true
                    }
                    title = "Failed requests"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 3
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 4
              y       = 2
            }
          }
          "15" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#00BCF2"
                        displayName = "Server response time"
                      }
                      name      = "requests/duration"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    openBladeOnClick = {
                      destinationBlade = {
                        bladeName     = "ResourceMenuBlade"
                        extensionName = "HubsExtension"
                        parameters = {
                          id     = azurerm_application_insights.authz_ai.id
                          menuid = "performance"
                        }
                      }
                      openBlade = true
                    }
                    title = "Server response time"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 8
              y       = 2
            }
          }
          "16" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#7E58FF"
                        displayName = "Page load network connect time"
                      }
                      name      = "browserTimings/networkDuration"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#44F1C8"
                        displayName = "Client processing time"
                      }
                      name      = "browserTimings/processingDuration"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#EB9371"
                        displayName = "Send request time"
                      }
                      name      = "browserTimings/sendDuration"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#0672F1"
                        displayName = "Receiving response time"
                      }
                      name      = "browserTimings/receiveDuration"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Average page load time breakdown"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 3
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 12
              y       = 2
            }
          }
          "17" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Availability"
                      }
                      name      = "availabilityResults/availabilityPercentage"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    openBladeOnClick = {
                      destinationBlade = {
                        bladeName     = "ResourceMenuBlade"
                        extensionName = "HubsExtension"
                        parameters = {
                          id     = azurerm_application_insights.authz_ai.id
                          menuid = "availability"
                        }
                      }
                      openBlade = true
                    }
                    title = "Average availability"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 3
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 0
              y       = 5
            }
          }
          "18" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 7
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Server exceptions"
                      }
                      name      = "exceptions/server"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 7
                      metricVisualization = {
                        color       = "#7E58FF"
                        displayName = "Dependency failures"
                      }
                      name      = "dependencies/failed"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Server exceptions and Dependency failures"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 4
              y       = 5
            }
          }
          "19" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Processor time"
                      }
                      name      = "performanceCounters/processorCpuPercentage"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                      }, {
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#7E58FF"
                        displayName = "Process CPU"
                      }
                      name      = "performanceCounters/processCpuPercentage"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Average processor and process CPU utilization"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 8
              y       = 5
            }
          }
          "2" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name  = "ResourceId"
                value = azurerm_application_insights.authz_ai.id
              }]
              type = "Extension/AppInsightsExtension/PartType/QuickPulseButtonSmallPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 3
              y       = 0
            }
          }
          "20" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 7
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Browser exceptions"
                      }
                      name      = "exceptions/browser"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Browser exceptions"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 12
              y       = 5
            }
          }
          "21" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 7
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Availability ${var.environment} results count"
                      }
                      name      = "availabilityResults/count"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Availability ${var.environment} results count"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 0
              y       = 8
            }
          }
          "22" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Process IO rate"
                      }
                      name      = "performanceCounters/processIOBytesPerSecond"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Average process I/O rate"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 4
              y       = 8
            }
          }
          "23" = {
            metadata = {
              inputs = [{
                name = "options"
                value = {
                  chart = {
                    metrics = [{
                      aggregationType = 4
                      metricVisualization = {
                        color       = "#47BDF5"
                        displayName = "Available memory"
                      }
                      name      = "performanceCounters/memoryAvailableBytes"
                      namespace = "microsoft.insights/components"
                      resourceMetadata = {
                        id = azurerm_application_insights.authz_ai.id
                      }
                    }]
                    title = "Average available memory"
                    visualization = {
                      axisVisualization = {
                        x = {
                          axisType  = 2
                          isVisible = true
                        }
                        y = {
                          axisType  = 1
                          isVisible = true
                        }
                      }
                      chartType = 2
                      legendVisualization = {
                        hideSubtitle = false
                        isVisible    = true
                        position     = 2
                      }
                    }
                  }
                }
                }, {
                isOptional = true
                name       = "sharedTimeRange"
              }]
              settings = {}
              type     = "Extension/HubsExtension/PartType/MonitorChartPart"
            }
            position = {
              colSpan = 4
              rowSpan = 3
              x       = 8
              y       = 8
            }
          }
          "3" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name = "TimeContext"
                value = {
                  createdTime           = "2018-05-04T01:20:33.345Z"
                  durationMs            = 86400000
                  endTime               = null
                  grain                 = 1
                  isInitialTime         = true
                  useDashboardTimeRange = false
                }
                }, {
                name  = "Version"
                value = "1.0"
              }]
              type = "Extension/AppInsightsExtension/PartType/AvailabilityNavButtonPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 4
              y       = 0
            }
          }
          "4" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name = "TimeContext"
                value = {
                  createdTime           = "2018-05-08T18:47:35.237Z"
                  durationMs            = 86400000
                  endTime               = null
                  grain                 = 1
                  isInitialTime         = true
                  useDashboardTimeRange = false
                }
                }, {
                name  = "ConfigurationId"
                value = "78ce933e-e864-4b05-a27b-71fd55a6afad"
              }]
              type = "Extension/AppInsightsExtension/PartType/AppMapButtonPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 5
              y       = 0
            }
          }
          "5" = {
            metadata = {
              inputs = []
              settings = {
                content = {
                  settings = {
                    content  = "# Usage"
                    subtitle = ""
                    title    = ""
                  }
                }
              }
              type = "Extension[azure]/HubsExtension/PartType/MarkdownPart"
            }
            position = {
              colSpan = 3
              rowSpan = 1
              x       = 0
              y       = 1
            }
          }
          "6" = {
            metadata = {
              asset = {
                idInputName = "ComponentId"
                type        = "ApplicationInsights"
              }
              inputs = [{
                name = "ComponentId"
                value = {
                  Name           = azurerm_application_insights.authz_ai.name
                  ResourceGroup  = azurerm_resource_group.rg.name
                  SubscriptionId = var.subscription_id
                }
                }, {
                name = "TimeContext"
                value = {
                  createdTime           = "2018-05-04T01:22:35.782Z"
                  durationMs            = 86400000
                  endTime               = null
                  grain                 = 1
                  isInitialTime         = true
                  useDashboardTimeRange = false
                }
              }]
              type = "Extension/AppInsightsExtension/PartType/UsageUsersOverviewPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 3
              y       = 1
            }
          }
          "7" = {
            metadata = {
              inputs = []
              settings = {
                content = {
                  settings = {
                    content  = "# Reliability"
                    subtitle = ""
                    title    = ""
                  }
                }
              }
              type = "Extension[azure]/HubsExtension/PartType/MarkdownPart"
            }
            position = {
              colSpan = 3
              rowSpan = 1
              x       = 4
              y       = 1
            }
          }
          "8" = {
            metadata = {
              asset = {
                idInputName = "ResourceId"
                type        = "ApplicationInsights"
              }
              defaultMenuItemId = "failures"
              inputs = [{
                name  = "ResourceId"
                value = azurerm_application_insights.authz_ai.id
                }, {
                isOptional = true
                name       = "DataModel"
                value = {
                  timeContext = {
                    createdTime           = "2018-05-04T23:42:40.072Z"
                    durationMs            = 86400000
                    grain                 = 1
                    isInitialTime         = false
                    useDashboardTimeRange = false
                  }
                  version = "1.0.0"
                }
                }, {
                isOptional = true
                name       = "ConfigurationId"
                value      = "8a02f7bf-ac0f-40e1-afe9-f0e72cfee77f"
              }]
              isAdapter = true
              type      = "Extension/AppInsightsExtension/PartType/CuratedBladeFailuresPinnedPart"
            }
            position = {
              colSpan = 1
              rowSpan = 1
              x       = 7
              y       = 1
            }
          }
          "9" = {
            metadata = {
              inputs = []
              settings = {
                content = {
                  settings = {
                    content  = "# Responsiveness\r\n"
                    subtitle = ""
                    title    = ""
                  }
                }
              }
              type = "Extension[azure]/HubsExtension/PartType/MarkdownPart"
            }
            position = {
              colSpan = 3
              rowSpan = 1
              x       = 8
              y       = 1
            }
          }
        }
      }
    }
  })
  location            = azurerm_resource_group.rg.location
  name                = "${azurerm_application_insights.authz_ai.name}-dashboard"
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    costcenter   = "altinn3"
    hidden-title = "${azurerm_application_insights.authz_ai.name} Dashboard"
    solution     = "apps"
  }
}
