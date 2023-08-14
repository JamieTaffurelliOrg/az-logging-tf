# az-logging-tf
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.app_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_automation_account.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) | resource |
| [azurerm_log_analytics_linked_service.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_service) | resource |
| [azurerm_log_analytics_solution.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.app_insights_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.automation_account_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.log_analytics_workspace_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account_child_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account_diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_storage_account.logging](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_insights"></a> [app\_insights](#input\_app\_insights) | Name of the Storage Account to deploy | <pre>object({<br>    name                                  = string<br>    application_type                      = optional(string, "other")<br>    daily_data_cap_in_gb                  = optional(number)<br>    daily_data_cap_notifications_disabled = optional(bool, false)<br>    retention_in_days                     = optional(number, 365)<br>    sampling_percentage                   = optional(number, 100)<br>    disable_ip_masking                    = optional(bool, false)<br>    local_authentication_disabled         = optional(bool, false)<br>    internet_ingestion_enabled            = optional(bool, true)<br>    internet_query_enabled                = optional(bool, true)<br>    force_customer_storage_for_profiler   = optional(bool, false)<br>  })</pre> | n/a | yes |
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | Name of the automation account to link to workspace | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Location to deploy resources | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of Log Analytics Workspace to deploy | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group to deploy to | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the Storage Account to deploy | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_automation_account_id"></a> [automation\_account\_id](#output\_automation\_account\_id) | Resource ID of the Automation Account |
| <a name="output_log_analytics_workspace_customer_id"></a> [log\_analytics\_workspace\_customer\_id](#output\_log\_analytics\_workspace\_customer\_id) | The Workspace (or Customer) ID for the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | Resource ID of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_primary_shared_key"></a> [log\_analytics\_workspace\_primary\_shared\_key](#output\_log\_analytics\_workspace\_primary\_shared\_key) | The Primary shared key for the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_secondary_shared_key"></a> [log\_analytics\_workspace\_secondary\_shared\_key](#output\_log\_analytics\_workspace\_secondary\_shared\_key) | The Secondary shared key for the Log Analytics Workspace |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | Resource ID of the Storage Account |
| <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key) | Primary Storage Account key |
| <a name="output_storage_account_primary_blob_endpoint"></a> [storage\_account\_primary\_blob\_endpoint](#output\_storage\_account\_primary\_blob\_endpoint) | Primary URL for blob endpoint |
| <a name="output_storage_account_secondary_access_key"></a> [storage\_account\_secondary\_access\_key](#output\_storage\_account\_secondary\_access\_key) | Secondary Storage Account key |
<!-- END_TF_DOCS -->
