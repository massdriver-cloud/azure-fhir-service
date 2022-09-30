resource "massdriver_artifact" "fhir" {
  field                = "azure_fhir_service"
  provider_resource_id = azurerm_healthcare_fhir_service.main.id
  name                 = "Azure FHIR Service ${var.md_metadata.name_prefix} (${azurerm_healthcare_fhir_service.main.id})"
  artifact = jsonencode(
    {
      data = {
        infrastructure = {
          ari = azurerm_healthcare_fhir_service.main.id
        }
        authentication = {
          authority = azurerm_healthcare_fhir_service.main.authentication[0].authority
          audience  = azurerm_healthcare_fhir_service.main.authentication[0].audience
        }
      }
    }
  )
}
