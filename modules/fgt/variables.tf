variable "resource_group_name" {}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}
variable "admin_password" {}

variable "prefix" {
  description = "Azure resourcers prefix description"
  type    = string
  default = "terraform"
}

variable "fgt_config" {
  type    = string
  default = ""
}

variable "fgt_ni_ids" {
  type    = list(string)
  default = null
}

variable "size" {
  description = "Check : https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes"
  type    = string
  default = "Standard_F4s"
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "tags" {
  description = "Azure resourcers tags"
  type = map(any)
  default = {
    Deploy  = "module-fgt-ha"
    Project = "terraform-fortinet"
  }
}

// License Type to create FortiGate-VM
// Provide the license type for FortiGate-VM Instances, either byol or payg.
variable "license_type" {
  type    = string
  default = "payg"
}

// AMI
variable "fgt_sku" {
  type = map(string)
  default = {
    byol = "fortinet_fg-vm"
    payg = "fortinet_fg-vm_payg_2023"
  }
}

variable "publisher" {
  type    = string
  default = "fortinet"
}

variable "fgt_offer" {
  type    = string
  default = "fortinet_fortigate-vm_v5"
}

variable "fgt_version" {
  type    = string
  default = "latest"
}
