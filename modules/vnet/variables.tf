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

// VNET details
variable "vnet" {
  description = "Subnet variables"
  type = object({
    name = optional(string, "")
    id   = optional(string, "")
    cidr = optional(string, "10.0.0.0/24")
    subnets = optional(map(map(string)), {
      public  = { "name" = "public", "cidr" = "10.0.0.0/26" }
      private = { "name" = "private", "cidr" = "10.0.0.62/26" }
      mgmt    = { "name" = "mgmt", "cidr" = "10.0.0.128/26" }
    })
  })
  default = {}
}