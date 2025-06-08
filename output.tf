output "subnet_cidrs" {
  value = module.fgt_vnet.subnet_cidrs
}

output "subnet_ids" {
  value = module.fgt_vnet.subnet_ids
}

output "fgt_nic_ids_list" {
  value = module.fgt_ni.nic_ids_list
}

output "fgt_nic_ips_map" {
  value = module.fgt_ni.nic_ips_map
}

output "fgt_ports_config_map" {
  value = module.fgt_ni.ports_config_map
}

output "hubs" {
  description = "VPN details for SDWAN spokes to connect to this HUB"
  sensitive   = true
  value       = local.o_hubs
}

#----------------------------------------------------------------------------------
# Debbuging
#----------------------------------------------------------------------------------
/*
output "fgt_config" {
  value = { for k, v in module.fgt_config : k => v.config }
}

output "nics_pair" {
  value = module.fgt_ni.nics_pair
}

output "index_public_nis" {
  value = module.fgt_ni.index_public_nis
}

output "public_key_openssh" {
  value = trimspace(tls_private_key.ssh.public_key_openssh)
}

output "resource_group_name" {
  value = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
}
*/

