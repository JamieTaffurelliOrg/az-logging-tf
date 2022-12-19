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

variable "network_watchers" {
  type = map(object(
    {
      name     = string
      location = string
    }
  ))
  description = "Name and loaction of the Network Watchers to deploy"
}

/*variable "data_collection_rule_template_path" {
  type        = string
  description = "Path to data collection rule arm template"
}*/

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
