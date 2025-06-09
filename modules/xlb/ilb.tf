#------------------------------------------------------------------------
# Create Internal LB
#------------------------------------------------------------------------
// Create Load Balancer
resource "azurerm_lb" "ilb" {
  name                = "${var.prefix}-ilb"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                          = "${var.prefix}-ilb-frontend"
    subnet_id                     = var.subnet_ids["private"]
    private_ip_address            = var.ilb_ip != null ? var.ilb_ip : cidrhost(var.subnet_cidrs["private"], var.cidr_host)
    private_ip_address_allocation = "Static"
  }
}
// Create backend pool
resource "azurerm_lb_backend_address_pool" "ilb_backend" {
  loadbalancer_id = azurerm_lb.ilb.id
  name            = "BackEndPool"
}

// Create healch-check
resource "azurerm_lb_probe" "ilb_probe" {
  loadbalancer_id     = azurerm_lb.ilb.id
  name                = "lbprobe"
  port                = var.backend_probe_port
  interval_in_seconds = 5
  number_of_probes    = 2
  protocol            = "Tcp"
}

// Create LB rule
resource "azurerm_lb_rule" "ilb_rule_haport" {
  loadbalancer_id                = azurerm_lb.ilb.id
  name                           = "ilb-rule-haport"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "${var.prefix}-ilb-frontend"
  probe_id                       = azurerm_lb_probe.ilb_probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.ilb_backend.id]
  load_distribution              = "SourceIP"
  enable_floating_ip             = var.ilb_floating_ip_enable
}

// Create BackEnd Pools associate to Fortigate IPs
resource "azurerm_lb_backend_address_pool_address" "ilb_backend_fgt" {
  for_each = var.fgt_ni_ips

  name                    = "BackEndPool-${each.key}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.ilb_backend.id
  virtual_network_id      = var.vnet_id
  ip_address              = each.value["private"]
}
