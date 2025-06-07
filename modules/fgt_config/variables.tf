#-----------------------------------------------------------------------------------
# Predefined variables for HA
# - config_fgcp   = true (default)
# - confgi_fgsp   = false (default)
#-----------------------------------------------------------------------------------
variable "config_fgcp" {
  type    = bool
  default = false
}
variable "config_fgsp" {
  type    = bool
  default = false
}

variable "config_ha_port" {
  type    = bool
  default = false
}

variable "fgt_id_prefix" {
  description = "Fortigate name prefix"
  type        = string
  default     = "fgt"
}

variable "cluster_member_id" {
  description = "Member ID of the cluster"
  type        = number
  default     = 1
}

variable "cluster_members" {
  description = "Map of string with details of cluster members"
  type        = map(map(map(string)))
  default     = {}
}

variable "fgsp_port" {
  description = "Type of port used to sync with other members of cluster in FGSP type"
  type        = string
  default     = "private"
}

variable "fgcp_port" {
  description = "Type of port used to sync with other members of cluster in FGCP type"
  type        = string
  default     = "mgmt"
}

variable "cluster_master_id" {
  description = "Name of fortigate instance acting as master of the cluster"
  type        = string
  default     = "fgt1"
}

variable "config_auto_scale" {
  description = "Boolean variable to configure auto-scale sync config between fortigates"
  type        = bool
  default     = false
}

variable "auto_scale_secret" {
  description = "Fortigate auto scale password"
  type        = string
  default     = null
}

variable "auto_scale_sync_port" {
  description = "Type of port used to sync config betweewn fortigates"
  type        = string
  default     = "private"
}

#-----------------------------------------------------------------------------------
# Default BGP configuration
#-----------------------------------------------------------------------------------
variable "bgp_asn_default" {
  type    = string
  default = "65000"
}

#-----------------------------------------------------------------------------------
# Predefined variables for SPOKE
# - config_spoke = false
#-----------------------------------------------------------------------------------
variable "config_spoke" {
  description = "Boolean varible to configure fortigate as SDWAN spoke"
  type        = bool
  default     = false
}

variable "spoke" {
  description = "Default parameters for a site"
  type = object({
    id      = optional(string, "fgt")
    cidr    = optional(string, "172.30.0.0/23")
    bgp_asn = optional(string, "65000")
  })
  default = {}
}

variable "hubs" {
  description = "Details to crate VPN connections and SDWAN config"
  type = list(object({
    id                = optional(string, "HUB")
    bgp_asn           = optional(string, "65000")
    external_ip       = optional(string, "") // leave in blank if use external_fqdn   
    external_fqdn     = optional(string, "") // leave in blank if use external_ip
    hub_ip            = optional(string, "172.20.30.1")
    site_ip           = optional(string, "")
    hck_ip            = optional(string, "172.20.30.1")
    vpn_psk           = optional(string, "secret-key-123")
    cidr              = optional(string, "172.20.30.0/24")
    ike_version       = optional(string, "2")
    network_id        = optional(string, "1")
    dpd_retryinterval = optional(string, "5")
    sdwan_port        = optional(string, "public")
  }))
  default = []
}

#-----------------------------------------------------------------------------------
# Predefined variables for HUB
# - config_hub   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_hub" {
  description = "Boolean varible to configure fortigate as a SDWAN HUB"
  type        = bool
  default     = false
}

variable "hub" {
  description = "Map of string with details to create VPN HUB"
  type = list(object({
    id                = optional(string, "HUB")
    bgp_asn_hub       = optional(string, "65000")
    bgp_asn_spoke     = optional(string, "65000")
    vpn_cidr          = optional(string, "10.1.1.0/24")
    vpn_psk           = optional(string, "secret-key-123")
    cidr              = optional(string, "172.30.0.0/24")
    ike_version       = optional(string, "2")
    network_id        = optional(string, "1")
    dpd_retryinterval = optional(string, "5")
    mode_cfg          = optional(string, true)
    vpn_port          = optional(string, "public")
  }))
  default = []
}

#-----------------------------------------------------------------------------------
# Config Site to Site tunnels
# - config_s2s   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_s2s" {
  description = "Boolean varible to configure IPSEC site to site connections"
  type        = bool
  default     = false
}

variable "s2s_peers" {
  description = "Details for site to site connections beteween fortigates"
  type = list(object({
    id                = optional(string, "s2s")
    remote_gw         = optional(string, "")
    bgp_asn_remote    = optional(string, "65000")
    vpn_port          = optional(string, "public")
    vpn_cidr          = optional(string, "10.10.10.0/27")
    vpn_psk           = optional(string, "")
    vpn_local_ip      = optional(string, "10.10.10.1")
    vpn_remote_ip     = optional(string, "10.10.10.2")
    ike_version       = optional(string, "2")
    network_id        = optional(string, "1")
    dpd_retryinterval = optional(string, "5")
    hck_ip            = optional(string, "10.10.10.2")
    remote_cidr       = optional(string, "172.16.0.0/12")
  }))
  default = []
}

#-----------------------------------------------------------------------------------
# Config VXLAN tunnels
#-----------------------------------------------------------------------------------
variable "config_vxlan" {
  description = "Boolean varible to configure VXLAN connections"
  type        = bool
  default     = false
}

variable "vxlan_peers" {
  description = "Details for vxlan connections beteween fortigates"
  type = list(object({
    external_ip   = optional(string, "")                      //Example "11.11.11.22,11.11.11.23" you should use comma separted IPs
    remote_ip     = optional(string, "10.10.30.2,10.10.30.3") //Comma separted IPs
    local_ip      = optional(string, "10.10.30.1")
    bgp_asn       = optional(string, "65000")
    vni           = optional(string, "1100")
    vxlan_port    = optional(string, "private")
    route_map_in  = optional(string, "")
    route_map_out = optional(string, "")
  }))
  default = []
}

#-----------------------------------------------------------------------------------
# Variables for xLB 
# - config_xlb = false (default) 
#-----------------------------------------------------------------------------------
variable "config_xlb" {
  type    = bool
  default = false
}
variable "ilb_ip" {
  type    = string
  default = ""
}
variable "elb_ip" {
  type    = string
  default = ""
}

#-----------------------------------------------------------------------------------
# Predefined variables for FMG 
# - config_fmg = false (default) 
#-----------------------------------------------------------------------------------
variable "config_fmg" {
  description = "Boolean varible to configure FortiManger"
  type        = bool
  default     = false
}

variable "fmg" {
  description = "FortiManager details"
  type = object({
    ip                      = optional(string, "")
    sn                      = optional(string, "")
    source_ip               = optional(string, "")
    interface_select_method = optional(string, "")
  })
  default = {}
}

#-----------------------------------------------------------------------------------
# Predefined variables for FAZ 
# - config_faz = false (default) 
#-----------------------------------------------------------------------------------
variable "config_faz" {
  description = "Boolean varible to configure FortiManger"
  type        = bool
  default     = false
}

variable "faz" {
  description = "FortiAnalyzer details"
  type = object({
    ip                      = optional(string, "")
    sn                      = optional(string, "")
    source_ip               = optional(string, "")
    interface_select_method = optional(string, "")
  })
  default = {}
}

#-----------------------------------------------------------------------------------
# Predefined variables to Azure Route Server
# - config_ars   = false (default) 
#-----------------------------------------------------------------------------------
variable "config_ars" {
  type    = bool
  default = false
}

variable "ars_peers" {
  description = "Azure Route Server IPs"
  type = object({
    ips     = optional(list(string), [])
    bgp_asn = optional(string, "65515")
  })
  default = {}
}

#-----------------------------------------------------------------------------------
# Predefined variables for GWLB (VXLAN Azure)
# - config_gwlb-vxlan = false (default) 
#-----------------------------------------------------------------------------------
variable "config_gwlb" {
  type    = bool
  default = false
}
variable "gwlb" {
  description = "Map of string with details for Azure GWLB"
  type = object({
    gwlb_ip  = optional(string, "")
    vdi_ext  = optional(string, "800")
    vdi_int  = optional(string, "801")
    port_ext = optional(string, "10800")
    port_int = optional(string, "10801")
  })
  default = {}
}

#-----------------------------------------------------------------------------------
# Variables for SDN connector
#-----------------------------------------------------------------------------------
variable "config_sdn" {
  description = "Boolean variable to configure SDN connector"
  type        = bool
  default     = false
}

variable "sdn_connector" {
  description = "SDN connector details"
  type = object({
    tenant              = optional(string, "")
    subscription        = optional(string, "")
    clientid            = optional(string, "")
    clientsecret        = optional(string, "")
    resource_group_name = optional(string, "")
    cluster_public_ip   = optional(string, "")
    cluster_private_ip  = optional(string, "")
    route_table         = optional(string, "")
  })
  default = {}
}

#-----------------------------------------------------------------------------------
# Licenses
#-----------------------------------------------------------------------------------
variable "license_type" {
  description = "Provide the license type for FortiGate-VM Instances, either byol or payg"
  type        = string
  default     = "payg"
}

variable "license_file" {
  description = "Change to your own byol license file, license.lic"
  type        = string
  default     = "./licenses/license.lic"
}

variable "fortiflex_token" {
  description = "FortiFlex token for BYOL license"
  type        = string
  default     = ""
}

#-----------------------------------------------------------------------------------
# Other variables
#-----------------------------------------------------------------------------------
variable "config_fw_policy" {
  description = "Boolean varible to configure default FortiGate firewall policy"
  type        = bool
  default     = true
}

variable "admin_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "admin_port" {
  type    = string
  default = "8443"
}

variable "api_key" {
  type    = string
  default = null
}

variable "config_extra" {
  type    = string
  default = ""
}

variable "rsa_public_key" {
  description = "SSH RSA public key for KeyPair if not exists"
  type        = string
  default     = null
}

variable "fgt_id" {
  description = "Fortigate name"
  type        = string
  default     = "fgt1"
}

variable "ports_config" {
  description = "Map of maps of ports details"
  type        = map(map(string))
  default     = {}
}

variable "static_route_cidrs" {
  description = "List of CIDRs to add as static routes"
  type        = list(string)
  default     = null
}