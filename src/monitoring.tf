locals {
  automated_alarms = {
    total_latency_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 500
    }
    availability_metric_alert = {
      severity    = "2"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 75
    }
    total_errors_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThan"
      aggregation = "Average"
      threshold   = 10
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }
  alarms             = lookup(local.alarms_map, var.monitoring.mode, {})
  monitoring_enabled = var.monitoring.mode != "DISABLED" ? 1 : 0
}

module "alarm_channel" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure/alarm-channel?ref=343d3e4"
  md_metadata         = var.md_metadata
  resource_group_name = azurerm_resource_group.main.name
}

module "total_latency_metric_alert" {
  count                   = local.monitoring_enabled
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=343d3e4"
  scopes                  = [azurerm_healthcare_fhir_service.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.total_latency_metric_alert.severity
  frequency               = local.alarms.total_latency_metric_alert.frequency
  window_size             = local.alarms.total_latency_metric_alert.window_size

  depends_on = [
    azurerm_healthcare_fhir_service.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Total Latency"
  message      = "High Amount of Latency"

  alarm_name       = "${var.md_metadata.name_prefix}-highTotalLatency"
  operator         = local.alarms.total_latency_metric_alert.operator
  metric_name      = "TotalLatency"
  metric_namespace = "microsoft.healthcareapis/workspaces/fhirservices"
  aggregation      = local.alarms.total_latency_metric_alert.aggregation
  threshold        = local.alarms.total_latency_metric_alert.threshold
}

module "availability_metric_alert" {
  count                   = local.monitoring_enabled
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=343d3e4"
  scopes                  = [azurerm_healthcare_fhir_service.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.availability_metric_alert.severity
  frequency               = local.alarms.availability_metric_alert.frequency
  window_size             = local.alarms.availability_metric_alert.window_size

  depends_on = [
    azurerm_healthcare_fhir_service.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Availability"
  message      = "Low service availability"

  alarm_name       = "${var.md_metadata.name_prefix}-lowAvailability"
  operator         = local.alarms.availability_metric_alert.operator
  metric_name      = "Availability"
  metric_namespace = "microsoft.healthcareapis/workspaces/fhirservices"
  aggregation      = local.alarms.availability_metric_alert.aggregation
  threshold        = local.alarms.availability_metric_alert.threshold
}

module "total_errors_metric_alert" {
  count                   = local.monitoring_enabled
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=343d3e4"
  scopes                  = [azurerm_healthcare_fhir_service.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.total_errors_metric_alert.severity
  frequency               = local.alarms.total_errors_metric_alert.frequency
  window_size             = local.alarms.total_errors_metric_alert.window_size

  depends_on = [
    azurerm_healthcare_fhir_service.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Total Errors"
  message      = "High Amount of Total Errors"

  alarm_name       = "${var.md_metadata.name_prefix}-highTotalErrors"
  operator         = local.alarms.total_errors_metric_alert.operator
  metric_name      = "TotalErrors"
  metric_namespace = "microsoft.healthcareapis/workspaces/fhirservices"
  aggregation      = local.alarms.total_errors_metric_alert.aggregation
  threshold        = local.alarms.total_errors_metric_alert.threshold
}
