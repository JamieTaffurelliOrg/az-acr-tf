resource "azurerm_container_registry" "acr" {
  name                          = var.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  export_policy_enabled         = var.export_policy_enabled
  anonymous_pull_enabled        = false
  data_endpoint_enabled         = var.data_endpoint_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option

  retention_policy {
    days    = var.retention_policy_days
    enabled = var.enable_retention_policy
  }

  trust_policy {
    enabled = var.enable_trust_policy
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "georeplications" {
    for_each = { for k in var.georeplications : k.location => k if k != null }

    content {
      location                = georeplications.key
      zone_redundancy_enabled = georeplications.value["zone_redundancy_enabled"]
      tags                    = var.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = var.sku != "Premium" ? {} : { "network_rule_set" = var.network_rule_set }
    content {
      default_action = network_rule_set.value["default_action"]

      dynamic "ip_rule" {
        for_each = { for k in network_rule_set.value["ip_rules"] : k.ip_range => k if k != null }

        content {
          action   = ip_rule.value["action"]
          ip_range = ip_rule.value["ip_range"]
        }
      }

      dynamic "virtual_network" {
        for_each = { for k in network_rule_set.value["virtual_network_rules"] : k.subnet_id => k if k != null }

        content {
          action    = virtual_network.value["action"]
          subnet_id = virtual_network.value["subnet_id"]
        }
      }
    }
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "private_endpoint" {
  for_each            = { for k in var.private_endpoints : k.name => k if k != null }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = each.value["location"]
  subnet_id           = each.value["subnet_id"]

  private_service_connection {
    name                           = each.value["private_service_connection_name"]
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "customdns"
    private_dns_zone_ids = each.value["private_dns_zone_ids"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "acr_diagnostics" {
  name                       = "${var.log_analytics_workspace_name}-security-logging"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
