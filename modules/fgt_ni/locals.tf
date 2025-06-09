locals {
  # ----------------------------------------------------------------------------------
  # Resource index
  # ----------------------------------------------------------------------------------
  index_nics_pairs = setproduct(range(var.fgt_number), var.fgt_subnet_names)

  index_nics = { for pair in local.index_nics_pairs :
    "${pair[0]}.${pair[1]}" => {
      subnet_id   = lookup(var.fgt_subnet_ids, pair[1], "")
      subnet_cidr = lookup(var.fgt_subnet_cidrs, pair[1], "")
      subnet_mask = cidrnetmask(lookup(var.fgt_subnet_cidrs, pair[1], ""))
      subnet_gw   = cidrhost(lookup(var.fgt_subnet_cidrs, pair[1], ""), 1)
      private_ip  = cidrhost(lookup(var.fgt_subnet_cidrs, pair[1], ""), var.cidr_host + pair[0])
      config_pip = anytrue([
        alltrue([strcontains(pair[1], "public"), var.config_pip_public]),
        alltrue([strcontains(pair[1], "mgmt"), var.config_pip_mgmt])
      ])
      nic_name = "fgt${pair[0] + 1}-${pair[1]}"
    }
  }

  nics_pair = { for k, v in local.index_nics :
    k => {
      subnet_id   = v.subnet_id
      subnet_cidr = v.subnet_cidr
      subnet_mask = v.subnet_mask
      subnet_gw   = v.subnet_gw
      private_ip  = v.private_ip
      public_pip  = lookup(azurerm_public_ip.public_ips, k, { "ip_address" = "" }).ip_address
      nic_id      = lookup(azurerm_network_interface.nics, k, { "id" = "" }).id
      nic_name    = v.nic_name
    }
  }

  # ----------------------------------------------------------------------------------
  # Output variables
  # ----------------------------------------------------------------------------------
  // Map of list of NIC IDs for each FGT
  o_nic_ids_list = { for i in range(var.fgt_number) :
    "fgt${i + 1}" => [for v in var.fgt_subnet_names :
      local.nics_pair["${i}.${v}"].nic_id
    ]
  }
  // Map of NIC IPs for each FGT
  o_nic_ips_map = { for i in range(var.fgt_number) :
    "fgt${i + 1}" => { for v in var.fgt_subnet_names :
      v => local.nics_pair["${i}.${v}"].private_ip
    }
  }
  // Map of FGT port config
  o_ports_config_map = { for i in range(var.fgt_number) :
    "fgt${i + 1}" => { for ii, v in var.fgt_subnet_names :
      "port${ii + 1}" => {
        port      = "port${ii + 1}"
        ip        = local.nics_pair["${i}.${v}"].private_ip
        mask      = local.nics_pair["${i}.${v}"].subnet_mask
        gw        = local.nics_pair["${i}.${v}"].subnet_gw
        cidr      = local.nics_pair["${i}.${v}"].subnet_cidr
        public_ip = local.nics_pair["${i}.${v}"].public_pip
        tag       = v
        nic_id    = local.nics_pair["${i}.${v}"].nic_id
        nic_name  = local.nics_pair["${i}.${v}"].nic_name
      }
    }
  }
}