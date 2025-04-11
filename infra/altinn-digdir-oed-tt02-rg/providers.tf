terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
  resource_providers_to_register = [
    "Microsoft.Monitor",
    "Microsoft.AlertsManagement",
    "Microsoft.Dashboard",
    "Microsoft.KubernetesConfiguration"
  ]
}
provider "random" {}

provider "grafana" {
  alias = "managed"
  url   = azurerm_dashboard_grafana.example.endpoint
  auth  = azurerm_dashboard_grafana.example.identity[0].principal_id
}

# Managed Grafana resource
resource "azurerm_dashboard_grafana" "example" {
  name                = "digdir-managed-grafana"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  grafana_major_version = "6"
  identity {
    type = "SystemAssigned"
  }
  sku = "Standard"
}
