output "nic_ids_list" {
  value = local.o_nic_ids_list
}

output "nic_ips_map" {
  value = local.o_nic_ips_map
}

output "ports_config_map" {
  value = local.o_ports_config_map
}

#----------------------------------------------------------------------------------
# Debbuging
#----------------------------------------------------------------------------------
output "index_nics" {
  value = local.index_nics
}
output "nics_pair" {
  value = local.nics_pair
}
output "nics" {
  value = azurerm_network_interface.nics
}