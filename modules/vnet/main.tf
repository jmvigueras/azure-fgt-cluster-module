locals {
  vnet_name = lookup(var.vnet, "name") != "" ? var.vnet.name : "${var.prefix}-vnet"
  vnet_id   = lookup(var.vnet, "id") != "" ? var.vnet.id : try(azurerm_virtual_network.vnet[0].id, "")
}
# Create VNET if not provided
resource "azurerm_virtual_network" "vnet" {
  count = lookup(var.vnet, "name") != "" ? 0 : 1

  name                = "${var.prefix}-vnet"
  address_space       = [lookup(var.vnet, "cidr")]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# Create subnets
resource "azurerm_subnet" "subnets" {
  depends_on = [azurerm_virtual_network.vnet]

  for_each = lookup(var.vnet, "subnets", {})

  name                 = "${var.prefix}-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [each.value.cidr]
}