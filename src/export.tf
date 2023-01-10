resource "azurerm_storage_account" "export" {
  count                     = var.database.export_data ? 1 : 0
  name                      = "${local.alphanumeric_name}export"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = true
  is_hns_enabled            = true
  min_tls_version           = "TLS1_2"
  tags                      = var.md_metadata.default_tags

  # network_rules {
  #   default_action             = "Deny"
  #   bypass                     = ["AzureServices", "Logging"]
  #   virtual_network_subnet_ids = [var.azure_virtual_network.data.infrastructure.default_subnet_id]
  # }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "export" {
  count                = var.database.export_data ? 1 : 0
  scope                = azurerm_storage_account.export[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_healthcare_fhir_service.main.identity[0].principal_id
}

resource "azurerm_storage_container" "export" {
  for_each              = { for sc in var.database.export_containers : sc.name => sc }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.export[0].name
  container_access_type = "private"
}
