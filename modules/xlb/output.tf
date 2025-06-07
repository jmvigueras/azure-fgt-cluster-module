output "ilb_private_ip" {
  value = azurerm_lb.ilb.private_ip_address
}

output "elb_public_ip" {
  value = azurerm_public_ip.elb_pip.ip_address
}