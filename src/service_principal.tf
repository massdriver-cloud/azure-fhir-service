data "azuread_client_config" "current" {}

resource "random_uuid" "main" {}

resource "azuread_application" "main" {
  display_name = var.md_metadata.name_prefix
  single_page_application {
    redirect_uris = [
      "https://${var.md_metadata.name_prefix}.azurewebsites.net/.auth/login/aad/callback"
      ]
  }
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false
}