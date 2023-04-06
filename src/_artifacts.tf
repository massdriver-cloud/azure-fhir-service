resource "massdriver_artifact" "azure_fhir_service" {
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
        security = {
          iam = {
            read = {
              scope = azurerm_healthcare_fhir_service.main.id
              role = "FHIR Data Reader"
            }
            write = {
              scope = azurerm_healthcare_fhir_service.main.id
              role = "FHIR Data Writer"
            }
            export = {
              scope = azurerm_healthcare_fhir_service.main.id
              role = "FHIR Data Exporter"
            }
            convert = {
              scope = azurerm_healthcare_fhir_service.main.id
              role = "FHIR Data Converter"
            }
          }
        }
      }
      specs = {
        azure = {
          region = azurerm_healthcare_fhir_service.main.location
        }
      }
    }
  )
}
