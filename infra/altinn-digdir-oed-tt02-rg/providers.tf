terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.15.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    # The pipeline identity may not purge in Key Vault; a purge attempt fails the apply after the delete.
    # Deleted vaults and secrets stay soft-deleted until the retention period ends.
    key_vault {
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_secrets_on_destroy = false
    }
  }
  # Explicit because azurerm 5.0 changes the default from "legacy" to "none".
  resource_provider_registrations = "legacy"
  resource_providers_to_register = [
    "Microsoft.Monitor",
    "Microsoft.AlertsManagement",
    "Microsoft.Dashboard",
    "Microsoft.KubernetesConfiguration"
  ]
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "random" {}
