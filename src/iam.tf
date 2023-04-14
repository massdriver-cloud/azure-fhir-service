resource "azurerm_role_assignment" "export" {
  scope                = var.azure_storage_account_data_lake.data.infrastructure.ari
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_healthcare_fhir_service.main.identity[0].principal_id
}

resource "azurerm_role_assignment" "log" {
  count                = var.logging.enable_logging ? 1 : 0
  scope                = azurerm_storage_account.diag-log[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_healthcare_fhir_service.main.identity[0].principal_id
}
