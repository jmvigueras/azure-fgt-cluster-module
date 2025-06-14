// Resource group name
variable "resource_group_name" {
  type    = string
  default = null
}

// Azure resourcers prefix description added in name
variable "prefix" {
  type    = string
  default = "terraform"
}

// Azure resourcers tags
variable "tags" {
  type = map(string)
  default = {
    deploy = "module-xlb"
  }
}

// Region for deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// Map of subnet IDs VNet FGT
variable "subnet_ids" {
  type    = map(string)
  default = null
}

// Map of subnet CIDRS VNet FGT
variable "subnet_cidrs" {
  type    = map(string)
  default = null
}

// VNET ID of FGT VNET for peering
variable "vnet_id" {
  type    = string
  default = null
}

// Fortigate IPs
variable "fgt_ni_ips" {
  type    = map(map(string))
  default = null
}

variable "gwlb_ip" {
  type    = string
  default = null 
}

variable "ilb_ip" {
  type    = string
  default = null
}

// Floating IPs
variable "elb_floating_ip_enable" {
  type = bool
  default = false
}
variable "ilb_floating_ip_enable" {
  type = bool
  default = false
}

// List of ports to open (listernes)
variable "elb_listeners" {
  type = map(string)
  default = {
    "80"   = "Tcp"
    "443"  = "Tcp"
    "500"  = "Udp"
    "4500" = "Udp"
    "4789" = "Udp"
  }
}

// Fortigate vxlan vdi and port config
variable "gwlb_vxlan" {
  type = map(string)
  default = {
    vdi_ext  = "800"
    vdi_int  = "801"
    port_ext = "10800"
    port_int = "10801"
  }
}

// Fortigate interface probe port
variable "backend_probe_port" {
  type    = string
  default = "8008"
}

variable "cidr_host" {
  type    = number
  default = 9
}

