#--------------------------------------------------------------------------------
# Create route table bastion
#--------------------------------------------------------------------------------
// Route-table definition
resource "azurerm_route_table" "rt" {
  name                = "${var.prefix}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  bgp_route_propagation_enabled = false

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }
}

// Route table association
resource "azurerm_subnet_route_table_association" "rta" {
  for_each = { for v in var.subnet_ids : v => v }

  subnet_id      = each.key
  route_table_id = azurerm_route_table.rt.id
}

