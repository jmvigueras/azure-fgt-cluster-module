#----------------------------------------------------------------------------------
# Create public IPs
#----------------------------------------------------------------------------------
resource "azurerm_public_ip" "public_ips" {
  for_each = { for k, v in local.index_nics : k => v if v.config_pip }

  name                = "${var.prefix}-${each.value["nic_name"]}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"

  tags = var.tags
}

#----------------------------------------------------------------------------------
# Create interfaces
#----------------------------------------------------------------------------------
resource "azurerm_network_interface" "nics" {
  for_each = local.index_nics

  name                           = "${var.prefix}-${each.value["nic_name"]}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = var.accelerate

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.private_ip
    primary                       = true
    public_ip_address_id          = lookup(azurerm_public_ip.public_ips, each.key, { "id" = null }).id
  }

  tags = var.tags
}

