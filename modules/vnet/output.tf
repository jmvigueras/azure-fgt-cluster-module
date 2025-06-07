output "name" {
  value = local.vnet_name
}

output "id" {
  value = local.vnet_id
}

output "subnet" {
  value = azurerm_subnet.subnets
}

output "subnet_names" {
  value = { for k, v in azurerm_subnet.subnets : k => v.name }
}

output "subnet_cidrs" {
  value = { for k, v in azurerm_subnet.subnets : k => v.address_prefixes[0] }
}

output "subnet_ids" {
  value = { for k, v in azurerm_subnet.subnets : k => v.id }
}