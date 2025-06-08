#------------------------------------------------------------------
# Deploy FortiGate Cluster in Azure
#------------------------------------------------------------------
// Module VNET for FGT
module "fgt_vnet" {
  source = "./modules/vnet"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = var.tags

  vnet = var.fgt_vnet
}
// Module FGT NICs
module "fgt_ni" {
  source = "./modules/fgt_ni"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = var.tags

  fgt_number       = var.fgt_number
  fgt_subnet_names = var.fgt_subnet_names
  fgt_subnet_ids   = module.fgt_vnet.subnet_ids
  fgt_subnet_cidrs = module.fgt_vnet.subnet_cidrs

  config_pip_mgmt   = var.config_pip_mgmt
  config_pip_public = var.config_pip_public
}
// FGT Config
module "fgt_config" {
  source = "./modules/fgt_config"

  for_each = module.fgt_ni.ports_config_map

  admin_cidr     = var.admin_cidr
  admin_port     = var.admin_port
  rsa_public_key = trimspace(tls_private_key.ssh.public_key_openssh)

  fgt_id          = each.key
  ports_config    = each.value
  cluster_members = module.fgt_ni.ports_config_map

  license_type    = var.license_type
  fortiflex_token = local.fortiflex_tokens[each.key]

  config_fgcp       = var.fgt_cluster_type == "fgcp" ? true : false
  config_fgsp       = var.fgt_cluster_type == "fgsp" ? true : false
  config_auto_scale = var.fgt_cluster_type == "fgsp" ? true : false

  config_spoke = var.config_spoke
  spoke        = var.spoke
  hubs         = var.hubs

  config_hub = var.config_hub
  hub        = var.hub

  static_route_cidrs = [var.fgt_vnet["cidr"]]
}
// Create FGT cluster
module "fgt" {
  source = "./modules/fgt"

  for_each = module.fgt_ni.nic_ids_list

  prefix              = "${var.prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = var.tags

  admin_username = var.admin_username
  admin_password = local.admin_password

  fgt_ni_ids = each.value
  fgt_config = module.fgt_config[each.key].config

  license_type = var.license_type
  fgt_version  = var.fgt_version
  size         = var.fgt_size
}
// Create load balancers
module "xlb" {
  depends_on = [module.fgt_vnet]
  source     = "./modules/xlb"

  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name == null ? azurerm_resource_group.rg[0].name : var.resource_group_name
  tags                = var.tags

  backend-probe_port = "8008"

  vnet_id      = module.fgt_vnet.id
  subnet_ids   = module.fgt_vnet.subnet_ids
  subnet_cidrs = module.fgt_vnet.subnet_cidrs
  fgt_ni_ips   = module.fgt_ni.nic_ips_map
}


#-----------------------------------------------------------------------
# Necessary Resources
#-----------------------------------------------------------------------
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh-key/${var.prefix}-ssh-key.pem"
  file_permission = "0600"
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}

# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}

# Create ramdom password for FortiGates
resource "random_string" "admin_password" {
  length           = 20
  special          = true
  override_special = "#?!&"
}

# Create Resource Group if it is null
resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == null ? 1 : 0
  name     = "${var.prefix}-rg"
  location = var.location

  tags = var.tags
}