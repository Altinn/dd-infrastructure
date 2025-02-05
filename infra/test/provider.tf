provider "azurerm" {
  features {
  }
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = "7b6f8f15-3a3e-43a2-b6ac-8eb6c06ad103"
  environment                     = "public"
}
