variable "prefix" {
  description = "Prefix to be added to all resources as a prefix"
  type        = string
  default     = "fgt-xlb"
}

variable "location" {
  description = "Azure region where the solution is deployed"
  type        = string
  default     = "francecentral"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = null
}

variable "storage-account_endpoint" {
  description = "Storage account endpoint"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    "environment" = "demo"
    "project"     = "terraform-fortinet"
  }
}

variable "admin_port" {
  description = "Fortigate admin port"
  type        = string
  default     = "8443"
}

variable "admin_cidr" {
  description = "Fortigate HA port"
  type        = string
  default     = "0.0.0.0/0"
}

variable "admin_username" {
  description = "FortiGate of admin_username"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "FortiGate admin password"
  type        = string
  default     = null
}

variable "license_type" {
  description = "value of license type"
  type        = string
  default     = "payg"
}

variable "fortiflex_tokens" {
  description = "List of FortiFlex licenses tokens"
  type        = list(string)
  default     = []
}

variable "fgt_size" {
  description = "FortiGate instance size"
  type        = string
  default     = "Standard_F4s"
}

variable "fgt_version" {
  description = "FortiGate version"
  type        = string
  default     = "7.4.7"
}

variable "ilb_ip" {
  description = "Private IP for internal Load Balancer"
  type        = string
  default     = null
}

variable "backend_probe_port" {
  description = "Private IP for internal Load Balancer"
  type        = string
  default     = null
}

variable "fgt_api_key_enabled" {
  description = "Create FortiGate API key"
  type        = bool
  default     = false
}

variable "fgt_cluster_type" {
  description = "Default cluster type for FortiGate deployment"
  validation {
    condition     = contains(["fgcp", "fgsp"], var.fgt_cluster_type)
    error_message = "fgt_cluster_type must be either 'fgcp' or 'fgsp'."
  }
  type    = string
  default = "fgcp"
}

variable "fgt_number" {
  description = "Number of FortiGate instances to deploy"
  type        = number
  default     = 2
}

variable "config_pip_mgmt" {
  description = "Create Public IP for management interface"
  type        = bool
  default     = true
}

variable "config_pip_public" {
  description = "Create Public IP for public interface"
  type        = bool
  default     = true
}

variable "fgt_subnet_names" {
  description = "List of subnet names for FortiGate subnets"
  type        = list(string)
  default     = ["public", "private", "mgmt"]
}

variable "fgt_vnet" {
  description = "FortiGate VNET map subnet details"
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