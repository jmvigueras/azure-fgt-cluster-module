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
  type = map(string)
  default = {
    deploy = "module-route"
  }
}

variable "routes" {
  type = map(map(string))
  default = {}
}

variable "subnet_ids" {
  type = list(string)
  default = {}
}