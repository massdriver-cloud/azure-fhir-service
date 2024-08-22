## Azure FHIR Service

The Azure FHIR Service provides a managed, secure, and compliant environment for sharing and storing healthcare data using the Fast Healthcare Interoperability Resources (FHIR) standard. It enables the handling of health data efficiently and securely within the Azure ecosystem.

### Design Decisions

- **Resource Group and Location:** The module provisions resources within a specified resource group and location in Azure, ensuring regional compliance and resource organization.
- **Security Roles:** The service assigns specific roles for reading, writing, exporting, and converting FHIR data, maintaining strict access control and data security.
- **Monitoring and Logging:** The module integrates Azure Monitor and Storage Accounts for diagnostics and logging to ensure operational visibility and compliance.
- **Azure Storage Connection:** The service is configured to interface with an Azure Storage Account for data export capabilities, leveraging Azure's secure and scalable storage solutions.
- **Automated Alarms:** Pre-configured alarms for monitoring metrics like latency, availability, and error rates ensure proactive monitoring and quick issue resolution.

## Runbook

### Connection Issues to Azure FHIR Service

If you encounter connection issues with the Azure FHIR Service:

1. Confirm the service URL and authentication credentials.
2. Verify network connectivity and firewall settings.

To check connectivity status, use the Azure CLI:

```sh
az network watcher show-connectivity --source-resource <your-vm-resource-id> --dest-address <fhir-service-url> --dest-port 443
```

**Expected Outcome:** You should see a connectivity status indicating the connection is successful. If not, investigate and resolve network or firewall issues.

### Authentication Failures

If there are issues related to authentication:

1. Ensure that the correct authority and audience URL are configured.
2. Check if the service principal has the necessary permissions.

To list role assignments for a service principal:

```sh
az role assignment list --assignee <service-principal-id> --all
```

**Expected Outcome:** The output should show roles including "FHIR Data Reader", "FHIR Data Writer", "FHIR Data Exporter", and "FHIR Data Converter". Lack of these roles would require configuration updates.

### High Latency Alerts

If the service reports high latency, you can investigate using the pre-configured Azure Monitor alerts.

To check the total latency metric for the past hour:

```sh
az monitor metrics list \
  --resource <fhir-service-resource-id> \
  --metric TotalLatency \
  --interval PT1H
```

**Expected Outcome:** The output should show the average and peak latencies. If latency is persistently high, consider scaling resources or investigating potential bottlenecks.

### Unavailability or Downtime

For issues related to the service being unavailable:

1. Check the Azure Service Health for any reported outages.
2. Review the availability metrics.

To check the availability metric for the past day:

```sh
az monitor metrics list \
  --resource <fhir-service-resource-id> \
  --metric Availability \
  --interval P1D
```

**Expected Outcome:** You should see availability percentages. Any value significantly below 100% could indicate an issue. Further investigation into resource status and Azure Service Health updates is recommended.

### Error Spike

When there is a spike in errors:

1. Ensure the FHIR Service configuration has not changed unexpectedly.
2. Review diagnostic logs for any recent issues.

To check the total errors metric for the past hour:

```sh
az monitor metrics list \
  --resource <fhir-service-resource-id> \
  --metric TotalErrors \
  --interval PT1H
```

**Expected Outcome:** The error count should be within acceptable limits. A high error count may indicate a configuration problem or a service health issue. Review logs and recent changes for root cause analysis.

By following these commands and leveraging the built-in functionalities, you can effectively manage and troubleshoot your Azure FHIR Service instances.

