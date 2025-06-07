#-------------------------------------------------------------------------------------
# FGT NSG
#-------------------------------------------------------------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
# FGT NSG HA MGMT
resource "azurerm_network_security_rule" "nsr-ingress" {
  for_each = var.ingress_allow_ports

  name                         = "${var.prefix}-${each.value.port}"
  priority                     = each.key
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = each.value.protocol
  source_port_range            = "*"
  destination_port_range       = each.value.port
  source_address_prefixes      = each.value.src_prefixes
  destination_address_prefixes = each.value.dst_prefixes
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_security_rule" "nsr-egress" {
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
  network_security_group_name = azurerm_network_security_group.nsg-mgmt-ha.name
}

#-------------------------------------------------------------------------------------
# Associate NSG to interfaces
# - Connect the security group to the network interfaces FGT active
resource "azurerm_network_interface_security_group_association" "nsg-associate" {
  for_each = { for nic in var.nic_list : nic => nic }

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.nsg.id
}
