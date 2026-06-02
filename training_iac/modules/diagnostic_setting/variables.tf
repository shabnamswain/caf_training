variable "name" {
  description = "Diagnostic setting name."
  type        = string
}

variable "target_resource_id" {
  description = "Resource ID of the Azure resource to collect diagnostics from."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the destination Log Analytics workspace."
  type        = string
}

variable "log_categories" {
  description = "List of log category names to enable. Must be valid for the target resource type."
  type        = list(string)
  default     = []
}

variable "metric_categories" {
  description = "List of metric category names to enable (e.g. [\"AllMetrics\"])."
  type        = list(string)
  default     = ["AllMetrics"]
}
