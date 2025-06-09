output "fgt" {
  value = {
    admin = var.admin_username
    pass  = local.admin_password
    fgt_1 = "https://${module.fgt_ni.ports_config_map["fgt1"]["port3"]["public_ip"]}:${var.admin_port}"
    fgt_2 = "https://${module.fgt_ni.ports_config_map["fgt2"]["port3"]["public_ip"]}:${var.admin_port}"
  }
}

output "api_key" {
  sensitive = true
  value     = module.fgt_config["fgt1"].api_key
}

output "vnet_id" {
  value = module.fgt_vnet.id
}

output "vnet_name" {
  value = module.fgt_vnet.name
}

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

output "xlb" {
  value = {
    elb_public_ip  = module.xlb.elb_public_ip
    ilb_private_ip = module.xlb.ilb_private_ip
  }
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

