locals {
  admin_password = var.admin_password == null ? random_string.admin_password.result : var.admin_password
  fortiflex_tokens = { for i in range(var.fgt_number) :
    "fgt${i + 1}" => try(var.fortiflex_tokens[i], "")
  }

  #-----------------------------------------------------------------------------------------------------
  # Outputs 
  #-----------------------------------------------------------------------------------------------------
  // Variable for spoke to connect to HUB
  o_hubs = var.config_hub ? [for i, v in var.hub : {
    id                = v["id"]
    bgp_asn           = v["bgp_asn_hub"]
    external_ip       = v["vpn_port"] == "public" ? module.xlb.elb_public_ip : module.xlb.ilb_private_ip
    hub_ip            = cidrhost(v["vpn_cidr"], 1)
    site_ip           = "" // set to "" if VPN mode-cfg is enable
    hck_ip            = cidrhost(v["vpn_cidr"], 1)
    vpn_psk           = module.fgt_config["fgt1"].vpn_psk
    cidr              = v["cidr"]
    ike_version       = v["ike_version"]
    network_id        = v["network_id"]
    dpd_retryinterval = v["dpd_retryinterval"]
    sdwan_port        = v["vpn_port"]
    }
  ] : []
}