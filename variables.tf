variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group to deploy to"
}

variable "location" {
  type        = string
  description = "Location to deploy resources"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to deploy"
}

variable "automation_account_name" {
  type        = string
  description = "Name of the automation account to link to workspace"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the Storage Account to deploy"
}

variable "app_insights" {
  type = object({
    name                                  = string
    application_type                      = optional(string, "other")
    daily_data_cap_in_gb                  = optional(number)
    daily_data_cap_notifications_disabled = optional(bool, false)
    retention_in_days                     = optional(number, 365)
    sampling_percentage                   = optional(number, 100)
    disable_ip_masking                    = optional(bool, false)
    local_authentication_disabled         = optional(bool, false)
    internet_ingestion_enabled            = optional(bool, true)
    internet_query_enabled                = optional(bool, true)
    force_customer_storage_for_profiler   = optional(bool, false)
  })
  description = "Name of the Storage Account to deploy"
}

/*variable "data_collection_rule_template_path" {
  type        = string
  description = "Path to data collection rule arm template"
}*/

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
