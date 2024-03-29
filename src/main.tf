locals {
  max_length        = 18
  alphanumeric_name = substr(replace(var.md_metadata.name_prefix, "/[^a-z0-9]/", ""), 0, local.max_length)
  data_lake_name    = element(split("/", var.azure_storage_account_data_lake.data.infrastructure.ari), index(split("/", var.azure_storage_account_data_lake.data.infrastructure.ari), "storageAccounts") + 1)

  cors = {
    headers            = ["*"]
    methods            = ["GET", "PUT", "POST", "DELETE"]
    max_age_in_seconds = 600
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.database.region
  tags     = var.md_metadata.default_tags
}

resource "azurerm_healthcare_workspace" "main" {
  name                = local.alphanumeric_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.md_metadata.default_tags
}

resource "azurerm_healthcare_fhir_service" "main" {
  name                                      = substr(var.md_metadata.name_prefix, 0, 24)
  location                                  = azurerm_resource_group.main.location
  resource_group_name                       = azurerm_resource_group.main.name
  workspace_id                              = azurerm_healthcare_workspace.main.id
  kind                                      = "fhir-R4"
  configuration_export_storage_account_name = local.data_lake_name
  tags                                      = var.md_metadata.default_tags

  authentication {
    # authority is used for token validation
    authority = "https://login.microsoftonline.com/${var.azure_service_principal.data.tenant_id}"
    # audience identifies intended recipients of the token
    audience = "https://${var.md_metadata.name_prefix}.fhir.azurehealthcareapis.com"
  }

  identity {
    type = "SystemAssigned"
  }

  # OCI Artifact allows the user to set multiple Azure Container Registries to store  FHIR Converter templates.
  dynamic "oci_artifact" {
    for_each = { for r in var.registry : r.login_server => r }
    content {
      login_server = oci_artifact.value.login_server
      image_name   = oci_artifact.value.image_name
    }
  }

  cors {
    allowed_origins    = var.database.allowed_origins
    allowed_headers    = local.cors.headers
    allowed_methods    = local.cors.methods
    max_age_in_seconds = local.cors.max_age_in_seconds
  }
}
