# Data sources for existing Entra ID groups
data "azuread_group" "admin_group" {
  object_id = var.entraid_admin_group_object_id
}

data "azuread_group" "read_group" {
  object_id = var.entraid_read_group_object_id
}

# Generate unique IDs for app roles and API scope
resource "random_uuid" "admin_role_id" {}
resource "random_uuid" "read_role_id" {}
resource "random_uuid" "access_token_scope_id" {}

# Entra ID Application with App Roles and API Scope
resource "azuread_application" "admin_ad_app" {
  display_name            = "${var.entraid_app_name_prefix}-${var.environment}-${var.entraid_app_name_suffix}"
  description             = var.entraid_app_description
  owners                  = [data.azurerm_client_config.current.object_id]
  group_membership_claims = ["None"]
  sign_in_audience        = "AzureADMyOrg"
  identifier_uris         = ["api://${azuread_application.admin_ad_app.client_id}"]

  # App Roles
  app_role {
    allowed_member_types = ["User"]
    description          = "Admin role for ${var.entraid_app_name_prefix}-${var.environment}-${var.entraid_app_name_suffix}"
    display_name         = "Admin"
    enabled              = true
    id                   = random_uuid.admin_role_id.result
    value                = "Admin"
  }

  app_role {
    allowed_member_types = ["User"]
    description          = "Read role for ${var.entraid_app_name_prefix}-${var.environment}-${var.entraid_app_name_suffix}"
    display_name         = "Read"
    enabled              = true
    id                   = random_uuid.read_role_id.result
    value                = "Read"
  }

  # SPA (Single Page Application) configuration
  single_page_application {
    redirect_uris = [
      var.entraid_spa_redirect_uri_localhost,
      var.entraid_spa_redirect_uri_production
    ]
  }

  # Enable access tokens and ID tokens for authentication
  # This is equivalent to checking "Access tokens" and "ID tokens" in Azure portal
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }

  # API configuration with exposed scope
  api {
    mapped_claims_enabled          = false
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to read access tokens"
      admin_consent_display_name = "Read access tokens"
      enabled                    = true
      id                         = random_uuid.access_token_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to read access tokens on your behalf"
      user_consent_display_name  = "Read access tokens"
      value                      = "AccessToken.Read"
    }
  }
}

# Service Principal (Enterprise App)
resource "azuread_service_principal" "admin_ad_app_sp" {
  client_id                    = azuread_application.admin_ad_app.client_id
  app_role_assignment_required = true
  owners                       = [data.azurerm_client_config.current.object_id]

  tags = ["terraform", "${var.entraid_app_name_prefix}-${var.environment}"]
}

# App Role Assignments - Admin Group to Admin Role
resource "azuread_app_role_assignment" "admin_group_to_admin_role" {
  app_role_id         = random_uuid.admin_role_id.result
  principal_object_id = data.azuread_group.admin_group.object_id
  resource_object_id  = azuread_service_principal.admin_ad_app_sp.object_id
}

# App Role Assignments - Read Group to Read Role
resource "azuread_app_role_assignment" "read_group_to_read_role" {
  app_role_id         = random_uuid.read_role_id.result
  principal_object_id = data.azuread_group.read_group.object_id
  resource_object_id  = azuread_service_principal.admin_ad_app_sp.object_id
}

resource "azuread_application_identifier_uri" "admin_ad_app_identifier_uri" {
  application_id = azuread_application.admin_ad_app.id
  identifier_uri = "api://${azuread_application.admin_ad_app.client_id}"
}