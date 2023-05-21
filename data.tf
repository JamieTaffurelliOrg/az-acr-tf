data "azurerm_log_analytics_workspace" "logs" {
  provider            = azurerm.logs
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.subnet_resource_group_name
}

data "azurerm_private_dns_zone" "private_dns_zones" {
  provider            = azurerm.dns
  for_each            = { for k in var.private_dns_zones : k.name => k if k != null }
  name                = each.key
  resource_group_name = each.value["resource_group_name"]
}
