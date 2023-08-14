resource "azurerm_log_analytics_workspace" "logging" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 365
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "logging" {
  for_each              = toset(local.solutions)
  solution_name         = each.value
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.logging.id
  workspace_name        = azurerm_log_analytics_workspace.logging.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${each.value}"
  }
}

resource "azurerm_monitor_diagnostic_setting" "log_analytics_workspace_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_log_analytics_workspace.logging.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id

  log {
    category = "Audit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_automation_account" "logging" {
  #checkov:skip=CKV2_AZURE_24:Public automation account may be unavoidable
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "automation_account_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_automation_account.logging.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "JobLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "JobStreams"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "DSCNodeStatus"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 365
    }
  }
}

resource "azurerm_storage_account" "logging" {
  #checkov:skip=CKV2_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV2_AZURE_18:This is unnecessary for most scenarios
  #checkov:skip=CKV2_AZURE_1:We may require some storage accounts to not have firewalls
  #checkov:skip=CKV_AZURE_59:Value is deprecated
  name                            = var.storage_account_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  access_tier                     = "Hot"
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 365
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 365
    }

    container_delete_retention_policy {
      days = 365
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_storage_account.logging.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id

  metric {
    category = "Transaction"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

locals {
  storageDiagnostics = ["blobServices", "fileServices", "tableServices", "queueServices"]
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_child_diagnostics" {
  for_each                   = toset(local.storageDiagnostics)
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = "${azurerm_storage_account.logging.id}/${each.value}/default/"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logging.id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_log_analytics_linked_service" "logging" {
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.logging.id
  read_access_id      = azurerm_automation_account.logging.id
}

resource "azurerm_application_insights" "app_insights" {
  name                                  = var.app_insights.name
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  workspace_id                          = azurerm_log_analytics_workspace.logging.id
  application_type                      = var.app_insights.application_type
  daily_data_cap_in_gb                  = var.app_insights.daily_data_cap_in_gb
  daily_data_cap_notifications_disabled = var.app_insights.daily_data_cap_notifications_disabled
  retention_in_days                     = var.app_insights.retention_in_days
  sampling_percentage                   = var.app_insights.sampling_percentage
  disable_ip_masking                    = var.app_insights.disable_ip_masking
  local_authentication_disabled         = var.app_insights.local_authentication_disabled
  internet_ingestion_enabled            = var.app_insights.internet_ingestion_enabled
  internet_query_enabled                = var.app_insights.internet_query_enabled
  force_customer_storage_for_profiler   = var.app_insights.force_customer_storage_for_profiler

  tags = var.tags
}

/*locals {
  event_sources = [
    {
      name           = "application"
      event_log_name = "Application"
    },
    {
      name           = "system"
      event_log_name = "System"
    },
    {
      name           = "task-diagnostic"
      event_log_name = "Microsoft-Windows-TaskScheduler/Diagnostic"
    },
    {
      name           = "task-maintenance"
      event_log_name = "Microsoft-Windows-TaskScheduler/Maintenance"
    },
    {
      name           = "task-operation"
      event_log_name = "Microsoft-Windows-TaskScheduler/Operational"
    }
  ]
}

resource "azurerm_log_analytics_datasource_windows_event" "events" {
  for_each            = { for event_source in local.event_sources : event_source.name => event_source }
  name                = each.value["name"]
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.logging.name
  event_log_name      = each.value["event_log_name"]
  event_types         = ["Error", "Warning", "Information"]
}

locals {
  perf_sources = [
    {
      name         = "apppoolwaspoolstate"
      object_name  = "APP_POOL_WAS"
      counter_name = "Current Application Pool State"
    },
    {
      name         = "apppoolwaspoolrec"
      object_name  = "APP_POOL_WAS"
      counter_name = "Total Application Pool Recycles"
    },
    {
      name         = "apppoolwasprocfail"
      object_name  = "APP_POOL_WAS"
      counter_name = "Total Worker Process Failures"
    },
    {
      name         = "logicaldiskfreespace"
      object_name  = "LogicalDisk"
      counter_name = "% Free Space"
    },
    {
      name         = "logicaldiskavgdiskread"
      object_name  = "LogicalDisk"
      counter_name = "Avg. Disk sec/Read"
    },
    {
      name         = "logicaldiskavgdiskwrite"
      object_name  = "LogicalDisk"
      counter_name = "Avg. Disk sec/Write"
    },
    {
      name         = "logicaldiskdiskqueue"
      object_name  = "LogicalDisk"
      counter_name = "Current Disk Queue Length"
    },
    {
      name         = "logicaldiskdiskread"
      object_name  = "LogicalDisk"
      counter_name = "Disk Reads/sec"
    },
    {
      name         = "logicaldiskdisktrans"
      object_name  = "LogicalDisk"
      counter_name = "Disk Transfers/sec"
    },
    {
      name         = "logicaldiskdiskwrite"
      object_name  = "LogicalDisk"
      counter_name = "Disk Writes/sec"
    },
    {
      name         = "logicaldiskfreemb"
      object_name  = "LogicalDisk"
      counter_name = "Free Megabytes"
    },
    {
      name         = "memoryusedbyte"
      object_name  = "Memory"
      counter_name = "% Committed Bytes In Use"
    },
    {
      name         = "memoryfreemb"
      object_name  = "Memory"
      counter_name = "Available MBytes"
    },
    {
      name         = "networkadapterbyterec"
      object_name  = "Network Adapter"
      counter_name = "Bytes Received/sec"
    },
    {
      name         = "networkadapterbytesent"
      object_name  = "Network Adapter"
      counter_name = "Bytes Sent/sec"
    },
    {
      name         = "networkinterfacebytetotal"
      object_name  = "Network Interface"
      counter_name = "Bytes Total/sec"
    },
    {
      name         = "sqlagentalertsactive"
      object_name  = "SQLAgent:Alerts"
      counter_name = "Activated Alerts"
    },
    {
      name         = "sqlagentalertsactivemin"
      object_name  = "SQLAgent:Alerts"
      counter_name = "Alerts Activated/minute"
    },
    {
      name         = "sqlagentjobsactive"
      object_name  = "SQLAgent:Jobs"
      counter_name = "Active Jobs"
    },
    {
      name         = "sqlagentjobsfail"
      object_name  = "SQLAgent:Jobs"
      counter_name = "Failed Jobs"
    },
    {
      name         = "sqlagentrestart"
      object_name  = "SQLAgent:Statistics"
      counter_name = "SQL Server Restarted"
    },
    {
      name         = "sqldatabasesbrthrough"
      object_name  = "SQLServer:Databases"
      counter_name = "Backup/Restore Throughput/sec"
    },
    {
      name         = "sqldatabasesfilesize"
      object_name  = "SQLServer:Databases"
      counter_name = "Data File(s) Size (KB)"
    },
    {
      name         = "sqllockswaitms"
      object_name  = "SQLServer:Locks"
      counter_name = "Average Wait Time (ms)"
    },
    {
      name         = "sqllockslockrequest"
      object_name  = "SQLServer:Locks"
      counter_name = "Lock Requests/sec"
    },
    {
      name         = "sqllockslocktimeout"
      object_name  = "SQLServer:Locks"
      counter_name = "Lock Timeouts (timeout > 0)/sec"
    },
    {
      name         = "sqllockslocktimeoutsec"
      object_name  = "SQLServer:Locks"
      counter_name = "Lock Timeouts/sec"
    },
    {
      name         = "sqllocksdeadlock"
      object_name  = "SQLServer:Locks"
      counter_name = "Number of Deadlocks/sec"
    },
    {
      name         = "sqltransfreetempkb"
      object_name  = "SQLServer:Transactions"
      counter_name = "Free Space in tempdb (KB"
    },
    {
      name         = "sqltranstransactions"
      object_name  = "SQLServer:Transactions"
      counter_name = "Transactions"
    },
    {
      name         = "systemprocqueue"
      object_name  = "System"
      counter_name = "Processor Queue Length"
    },
    {
      name         = "tcpv4connfail"
      object_name  = "TCPv4"
      counter_name = "Connection Failures"
    },
    {
      name         = "tcpv4connact"
      object_name  = "TCPv4"
      counter_name = "Connections Active"
    },
    {
      name         = "tcpv4connest"
      object_name  = "TCPv4"
      counter_name = "Connections Established"
    }
  ]
}

resource "azurerm_log_analytics_datasource_windows_performance_counter" "perf" {
  for_each            = { for perf_source in local.perf_sources : perf_source.name => perf_source }
  name                = each.value["name"]
  resource_group_name = var.resource_group_name
  workspace_name      = azurerm_log_analytics_workspace.logging.name
  object_name         = each.value["object_name"]
  instance_name       = "*"
  counter_name        = each.value["counter_name"]
  interval_seconds    = 60
}

resource "azurerm_resource_group_template_deployment" "vmguesthealth" {
  name                = "vm-guest-health"
  resource_group_name = var.resource_group_name
  template_content    = file("arm/vmInsightsDataCollectionRule.json")
  parameters_content = jsonencode({
    "location" = {
      value = var.location
    },
    "destinationWorkspaceResourceId" = {
      value = azurerm_log_analytics_workspace.logging.id
    },
    "tags" = {
      value = var.tags
    }
  })
  deployment_mode = "Incremental"
  depends_on      = [azurerm_log_analytics_solution.logging]
}*/
