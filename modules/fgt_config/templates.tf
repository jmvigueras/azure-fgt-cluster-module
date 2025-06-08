locals {
  # ----------------------------------------------------------------------------------
  # FGT config
  # ----------------------------------------------------------------------------------
  fgt_config = templatefile("${path.module}/templates/fgt_all.conf", {
    fgt_id         = local.fgt_id
    admin_port     = var.admin_port
    admin_cidr     = var.admin_cidr
    adminusername  = "azureadmin"
    rsa_public_key = trimspace(var.rsa_public_key)
    api_key        = var.api_key == null ? random_string.api_key.result : var.api_key

    config_basic      = local.config_basic
    config_interfaces = local.config_interfaces

    config_fw_policy = var.config_fw_policy ? local.config_fw_policy : ""
    config_fgcp      = var.config_fgcp ? local.config_fgcp : ""
    config_fgsp      = var.config_fgsp ? local.config_fgsp : ""
    config_scale     = var.config_auto_scale ? local.config_auto_scale : ""
    config_route     = var.static_route_cidrs != null ? local.config_route : ""
    config_sdwan     = var.config_spoke ? local.config_sdwan : ""
    config_hub       = var.config_hub ? local.config_hub : ""
    config_vxlan     = var.config_vxlan ? local.config_vxlan : ""
    config_fmg       = var.config_fmg ? local.config_fmg : ""
    config_faz       = var.config_faz ? local.config_faz : ""
    config_xlb       = var.config_xlb ? local.config_xlb : ""
    config_ars       = var.config_ars ? local.config_ars : ""
    config_sdn       = var.config_sdn ? local.config_sdn : ""
    config_gwlb      = var.config_gwlb ? local.config_gwlb : ""

    config_extra = var.config_extra
  })

  # ----------------------------------------------------------------------------------
  # Individual config locals
  # ----------------------------------------------------------------------------------
  # Config for FortiGate basic settings
  config_basic = templatefile("${path.module}/templates/fgt_basic.conf", {
    license_type = var.license_type
    license_file = var.license_file
    flex_token   = var.fortiflex_token
    port         = local.port1_config["port"]
    ip           = local.port1_config["ip"]
    mask         = local.port1_config["mask"]
    gw           = local.port1_config["gw"]
  })

  # Config for FortiGate allow-all firewall policy
  config_fw_policy = templatefile("${path.module}/templates/fgt_fw_policy.conf", {
    port = local.port1_config["port"]
  })

  # Config for FortiGate interfaces
  config_interfaces = join("\n", [for k, v in local.ports_config :
    templatefile("${path.module}/templates/fgt_interface.conf", {
      port         = k
      ip           = v["ip"]
      mask         = v["mask"]
      gw           = v["gw"]
      alias        = v["tag"]
      allow_access = v["tag"] == "mgmt" ? "ping https ssh" : "ping https probe-response"
    })
  ])

  # Config for FortiGate HA FGCP
  config_fgcp = templatefile("${path.module}/templates/fgt_ha_fgcp.conf", {
    fgt_priority = local.fgcp_priority
    ha_port      = local.fgcp_port
    ha_gw        = local.fgcp_gw
    peerip       = local.fgcp_peer_ip == null ? "" : local.fgcp_peer_ip
  })

  # Config for FortiGate HA FGSP
  config_fgsp = templatefile("${path.module}/templates/fgt_ha_fgsp.conf", {
    mgmt_port = lookup(local.map_type_port, "mgmt", "")
    mgmt_gw   = lookup(local.map_type_gw, "mgmt", "")
    peers_list = join("\n", [for k, v in local.cluster_peer_ips :
      templatefile("${path.module}/templates/fgt_ha_fgsp_peers.conf", {
        id   = k
        ip   = v[local.fgsp_port_name]
        vdom = "root"
      })
    ])
    member_id = local.cluster_member_id
  })

  # Config for static routes
  config_route = templatefile("${path.module}/templates/fgt_static.conf", {
    route_cidrs = var.static_route_cidrs
    port        = local.map_type_port["private"]
    gw          = local.map_type_gw["private"]
  })

  # Config for auto-scale cluster
  config_auto_scale = templatefile("${path.module}/templates/fgt_auto_scale.conf", {
    sync_port     = lookup(local.map_type_port, var.auto_scale_sync_port, "")
    master_secret = local.auto_scale_secret
    master_ip     = local.fgsp_master_ip == null ? "" : local.fgsp_master_ip
  })

  # Config for SDWAN spoke
  config_sdwan = join("\n", [for i, v in var.hubs :
    templatefile("${path.module}/templates/fgt_sdwan.conf", {
      hub_id             = lookup(v, "id", "HUB")
      hub_ipsec_id       = "${lookup(v, "id", "HUB")}_ipsec_${i + 1}"
      hub_vpn_psk        = lookup(v, "vpn_psk", random_string.vpn_psk.result)
      hub_external_ip    = lookup(v, "external_ip", "")
      hub_external_fqdn  = lookup(v, "external_fqdn", "")
      hub_private_ip     = lookup(v, "private_ip", "")
      hub_bgp_asn        = lookup(v, "bgp_asn", "65000")
      hub_cidr           = lookup(v, "cidr", "10.0.0.0/8")
      site_private_ip    = lookup(v, "site_private_ip", "")
      hck_ip             = lookup(v, "hck_ip", "")
      network_id         = lookup(v, "network_id", "1")
      ike_version        = lookup(v, "ike_version", "2")
      dpd_retryinterval  = lookup(v, "dpd_retryinterval", "5")
      local_id           = lookup(var.spoke, "id", "spoke")
      local_router_id    = local.map_type_ip["public"]
      local_network      = lookup(var.spoke, "cidr", "")
      sdwan_port         = local.map_type_port[lookup(v, "sdwan_port", "public")]
      route_map_out      = lookup(v, "route_map_out", "")
      route_map_out_pref = lookup(v, "route_map_out_pref", "")
      route_map_in       = lookup(v, "route_map_in", "")
      count              = i + 1
    })]
  )

  # Config for HUB VPN
  config_hub = join("\n", [for i, v in var.hub :
    templatefile("${path.module}/templates/fgt_vpn_hub.conf", {
      hub_private_ip        = cidrhost(cidrsubnet(v["vpn_cidr"], 1, 0), 1)
      hub_remote_ip         = cidrhost(cidrsubnet(v["vpn_cidr"], 1, 0), 2)
      network_id            = lookup(v, "network_id", "1")
      ike_version           = lookup(v, "ike_version", "2")
      dpd_retryinterval     = lookup(v, "dpd_retryinterval", "5")
      local_id              = v["id"]
      local_network         = v["cidr"]
      local_gw              = lookup(v, "local_gw", "")
      fgsp_sync             = var.config_fgsp
      mode_cfg              = lookup(v, "mode_cfg", true)
      site_private_ip_start = cidrhost(cidrsubnet(v["vpn_cidr"], 1, 0), 3)
      site_private_ip_end   = cidrhost(cidrsubnet(v["vpn_cidr"], 1, 0), -2)
      site_private_ip_mask  = cidrnetmask(cidrsubnet(v["vpn_cidr"], 1, 0))
      site_bgp_asn          = v["bgp_asn_spoke"]
      vpn_psk               = lookup(v, "vpn_psk", random_string.vpn_psk.result)
      vpn_cidr              = cidrsubnet(v["vpn_cidr"], 1, 0)
      vpn_port              = local.map_type_port[lookup(v, "vpn_port", "public")]
      vpn_name              = "vpn-${local.map_type_port[lookup(v, "vpn_port", "public")]}"
      route_map_out         = lookup(v, "route_map_out", "")
      route_map_in          = lookup(v, "route_map_in", "")
      count                 = i + 1
    })]
  )

  # Config for vxlan
  config_vxlan = join("\n", local.config_vxlan_peers, local.config_vxlan_bgp)
  # Config for vxlan peers
  config_vxlan_peers = [for i, v in var.vxlan_peers :
    templatefile("${path.module}/templates/fgt_vxlan.conf", {
      vni         = v["vni"]
      external_ip = replace(v["external_ip"], ",", " ")
      local_ip    = v["local_ip"]
      vxlan_port  = local.map_type_port[v["vxlan_port"]]
      count       = i + 1
    })
  ]
  # Config for vxlan BGP peers
  config_vxlan_bgp = [for i, v in var.vxlan_peers :
    templatefile("${path.module}/templates/fgt_vxlan_bgp.conf", {
      remote_ip     = v["remote_ip"]
      bgp_asn       = v["bgp_asn"]
      route_map_out = v["route_map_out"]
      route_map_in  = v["route_map_in"]
    })
  ]

  # Config FortiAnalyzer
  config_faz = templatefile("${path.module}/templates/fgt_faz.conf", {
    ip                      = lookup(var.faz, "ip", "")
    sn                      = lookup(var.faz, "sn", "")
    source_ip               = lookup(var.faz, "source_ip", "")
    interface_select_method = lookup(var.faz, "interface_select_method", "")
  })

  # Config FortiManager
  config_fmg = templatefile("${path.module}/templates/fgt_fmg.conf", {
    ip                      = lookup(var.fmg, "ip", "")
    sn                      = lookup(var.fmg, "sn", "")
    source_ip               = lookup(var.fmg, "source_ip", "")
    interface_select_method = lookup(var.fmg, "interface_select_method", "")
  })

  # Config for Azure Load Balancer
  config_xlb = templatefile("${path.module}/templates/az_fgt_xlb.conf", {
    private_port = local.map_type_port["private"]
    public_port  = local.map_type_port["public"]
    ilb_ip       = var.ilb_ip
    elb_ip       = var.elb_ip
  })

  # Config for Azure Route Server
  config_ars = templatefile("${path.module}/templates/az_fgt_ars_bgp.conf", {
    ars_peers       = try(lookup(var.hub[0], "ips"), null)
    ars_bgp_asn     = try(lookup(var.hub[0], "bgp_asn"), "65515")
    local_router_id = local.map_type_ip["public"]
    route_map_out   = ""
  })

  # Config default BGP config
  fgt_bgp_asn = try(lookup(var.hub[0], "bgp_asn_hub"), lookup(var.spoke, "bgp_asn"), var.bgp_asn_default)
  config_default_bgp = templatefile("${path.module}/templates/fgt_bgp_default.conf", {
    bgp_asn        = local.fgt_bgp_asn
    community      = "10"
    remote_bgp_asn = try(lookup(var.hub[0], "bgp_asn_hub"), "")
    router_id      = local.map_type_ip["public"]
  })

  # Config for Azure SDN Connector
  config_sdn = templatefile("${path.module}/templates/az_fgt_sdn.conf", {
    tenant              = lookup(var.sdn_connector, "tenant", "")
    subscription        = lookup(var.sdn_connector, "subscription", "")
    clientid            = lookup(var.sdn_connector, "clientid", "")
    clientsecret        = lookup(var.sdn_connector, "clientsecret", "")
    resource_group_name = lookup(var.sdn_connector, "resource_group_name", "")

    nic_name          = local.map_type_nic_name["private"]
    cluster_public_ip = lookup(var.sdn_connector, "cluster_public_ip", "")
    route_table       = lookup(var.sdn_connector, "route_table", "")
    private_ip        = local.map_type_ip["private"]
  })

  # Config for Azure Gateway Load Balancer
  config_gwlb = templatefile("${path.module}/templates/az_fgt_gwlb.conf", {
    gwlb_ip      = lookup(var.gwlb, "gwlb_ip", "")
    vdi_ext      = lookup(var.gwlb, "vdi_ext", "")
    vdi_int      = lookup(var.gwlb, "vdi_int", "")
    port_ext     = lookup(var.gwlb, "port_ext", "")
    port_int     = lookup(var.gwlb, "port_int", "")
    private_port = local.map_type_ip["private"]
  })

}

