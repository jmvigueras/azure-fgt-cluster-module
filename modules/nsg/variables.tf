// Azure resourcers group
variable "resource_group_name" {
  type    = string
  default = null
}

// Region for deployment
variable "location" {
  type    = string
  default = "francecentral"
}

// Azure resourcers prefix description added in name
variable "prefix" {
  type    = string
  default = "module-vnet-fgt"
}

// Azure resourcers tags
variable "tags" {
  type = map(any)
  default = {
    deploy = "module-vnet-fgt"
  }
}

// HTTPS Port
variable "admin_port" {
  type    = string
  default = "8443"
}

variable "admin_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ingress_allow_ports" {
  type    = map(map(string))
  default = {}
}

variable "nic_list" {
  type    = list(string)
  default = {}
}