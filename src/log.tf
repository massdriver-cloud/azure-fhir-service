resource "azurerm_storage_account" "diag-log" {
  count                         = var.logging.enable_logging ? 1 : 0
  name                          = "${local.alphanumeric_name}log"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  enable_https_traffic_only     = true
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"
  tags                          = var.md_metadata.default_tags

  # This is a recommendation from BridgeCrew to enable logging for storage account queues, even though we aren't using queues in this bundle.
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

resource "azurerm_monitor_diagnostic_setting" "diag-log" {
  count              = var.logging.enable_logging ? 1 : 0
  name               = var.md_metadata.name_prefix
  target_resource_id = azurerm_healthcare_fhir_service.main.id
  storage_account_id = azurerm_storage_account.diag-log[0].id

  log {
    category = "AuditLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 7
    }
  }
}
