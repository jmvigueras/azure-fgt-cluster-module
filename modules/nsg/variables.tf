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
  description = "List of allowed ports with index as priority"
  type = map(object(
    {
      port         = string
      protocol     = string
      src_prefixes = list(string)
      dst_prefixes = list(string)
    }
  ))
  default = {
    "1001" = { "port" = "80", "protocol" = "Tcp", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
    "1002" = { "port" = "443", "protocol" = "Tcp", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
  }
}

variable "nic_list" {
  description = "Map of ports IDs to asociate the NSG"
  type        = list(string)
  default     = {}
}