output "nsg_ids" {
  value = {
    mgmt    = azurerm_network_security_group.nsg-mgmt-ha.id
    public  = azurerm_network_security_group.nsg-public.id
    private = azurerm_network_security_group.nsg-private.id
  }
}