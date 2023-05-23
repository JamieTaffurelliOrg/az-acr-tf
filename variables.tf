variable "container_registry_name" {
  type        = string
  description = "The name of the container registry to deploy"
}

variable "location" {
  type        = string
  description = "The primary location of the container registry"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group to deploy the container registry to"
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The sku of the container registry"
}

variable "admin_enabled" {
  type        = bool
  default     = false
  description = "Enable admin user"
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "Enable access to registry from public internet"
}

variable "quarantine_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable quarantine policy"
}

variable "zone_redundancy_enabled" {
  type        = bool
  default     = false
  description = "Enable zone redundancy"
}

variable "export_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable export policy"
}

variable "data_endpoint_enabled" {
  type        = bool
  default     = false
  description = "Enable data endpoint"
}

variable "network_rule_bypass_option" {
  type        = string
  default     = "AzureServices"
  description = "Allow trusted Microsoft services to access container registry"
}

variable "retention_policy_days" {
  type        = number
  default     = 7
  description = "The number of days to retain images with untagged manifests"
}

variable "enable_retention_policy" {
  type        = bool
  default     = true
  description = "Enable retention policy"
}

variable "enable_trust_policy" {
  type        = bool
  default     = true
  description = "Enable content trust policy"
}

variable "georeplications" {
  type = list(object(
    {
      location                = string
      zone_redundancy_enabled = bool
    }
  ))
  default     = []
  description = "Regions to geo-replicate to"
}

variable "network_rule_set" {
  type = object({
    default_action = optional(string, "Deny")
    ip_rules = optional(list(object({
      action   = optional(string, "Allow")
      ip_range = string
    })), [])
    virtual_network_rules = optional(list(object({
      action    = optional(string, "Allow")
      subnet_id = string
    })), [])
  })
  default     = {}
  description = "ACR firewall configuration"
}

variable "private_endpoints" {
  type = list(object({
    name                            = string
    location                        = string
    subnet_id                       = string
    private_service_connection_name = string
    private_dns_zone_ids            = list(string)
  }))
  default     = []
  description = "Private DNS zones to link to ACR Private Endpoint"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Name of Log Analytics Workspace to send diagnostics"
}

variable "log_analytics_workspace_resource_group_name" {
  type        = string
  description = "Resource Group of Log Analytics Workspace to send diagnostics"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
}
