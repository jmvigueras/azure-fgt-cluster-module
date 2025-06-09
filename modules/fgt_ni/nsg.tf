#-------------------------------------------------------------------------------------
# FGT NSG
#-------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg_mgmt" {
  name                = "${var.prefix}-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
resource "azurerm_network_security_group" "nsg_public" {
  name                = "${var.prefix}-public"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# FGT NSG HA MGMT
resource "azurerm_network_security_rule" "nsr_mgmt_ingress" {
  for_each = var.nsg_mgmt_allow_ports

  name                         = "${var.prefix}-${each.key}"
  priority                     = each.key
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = each.value.protocol
  source_port_range            = "*"
  destination_port_range       = each.value.port
  source_address_prefixes      = each.value.src_prefixes
  destination_address_prefixes = each.value.dst_prefixes
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg_mgmt.name
}
resource "azurerm_network_security_rule" "nsr_mgmt_egress" {
  name                        = "${var.prefix}-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_mgmt.name
}
# FGT NSG PUBLIC
resource "azurerm_network_security_rule" "nsr_public_ingress" {
  for_each = var.nsg_public_allow_ports

  name                         = "${var.prefix}-${each.key}"
  priority                     = each.key
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = each.value.protocol
  source_port_range            = "*"
  destination_port_range       = each.value.port
  source_address_prefixes      = each.value.src_prefixes
  destination_address_prefixes = each.value.dst_prefixes
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg_public.name
}
resource "azurerm_network_security_rule" "nsr_public_egress" {
  name                        = "${var.prefix}-all"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_public.name
}
#-------------------------------------------------------------------------------------
# Associate NSG to interfaces
# - Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "nsg_public_associate" {
  for_each = { for k, v in local.nics_pair : k => v if strcontains(k, "public") }

  network_interface_id      = each.value["nic_id"]
  network_security_group_id = azurerm_network_security_group.nsg_public.id
}
resource "azurerm_network_interface_security_group_association" "nsg_mgmt_associate" {
  for_each = { for k, v in local.nics_pair : k => v if strcontains(k, "mgmt") }

  network_interface_id      = each.value["nic_id"]
  network_security_group_id = azurerm_network_security_group.nsg_mgmt.id
}
