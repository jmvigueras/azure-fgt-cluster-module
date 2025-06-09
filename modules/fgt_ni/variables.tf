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

// enable accelerate network, either true or false, default is false
// Make the the instance choosed supports accelerated networking.
// Check: https://docs.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview#supported-vm-instances
variable "accelerate" {
  type        = bool
  default     = true
  description = "Boolean viriable to config accelerated interfaces"
  validation {
    condition     = can(regex("^([t][r][u][e]|[f][a][l][s][e])$", var.accelerate))
    error_message = "accelerate must be either true or false."
  }
}

variable "fgt_number" {
  type    = number
  default = 2
}

variable "fgt_subnet_names" {
  type    = list(string)
  default = ["public", "private", "mgmt"]
}

variable "fgt_subnet_ids" {
  type    = map(string)
  default = {}
}

variable "fgt_subnet_cidrs" {
  type    = map(string)
  default = {}
}

variable "config_pip_mgmt" {
  type    = bool
  default = true
}

variable "config_pip_public" {
  type    = bool
  default = true
}

variable "cidr_host" {
  type    = number
  default = 10
}

variable "nsg_mgmt_allow_ports" {
  description = "Details of rules to create in the NSG Management"
  type = map(object(
    {
      port         = string
      protocol     = string
      src_prefixes = list(string)
      dst_prefixes = list(string)
    }
  ))
  default = {
    "1001" = { "port" = "22", "protocol" = "Tcp", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
    "1002" = { "port" = "443", "protocol" = "Tcp", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
    "1003" = { "port" = "8443", "protocol" = "Tcp", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
  }
}

variable "nsg_public_allow_ports" {
  description = "Details of rules to create in the NSG Public"
  type = map(object(
    {
      port         = string
      protocol     = string
      src_prefixes = list(string)
      dst_prefixes = list(string)
    }
  ))
  default = {
    "1001" = { "port" = "*", "protocol" = "*", "src_prefixes" = ["0.0.0.0/0"], "dst_prefixes" = ["0.0.0.0/0"] }
  }
}