# Azure FortiGate Cluster Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg?style=for-the-badge)](LICENSE)

A Terraform module for deploying FortiGate clusters on Microsoft Azure with support for both FGCP (FortiGate Clustering Protocol) and FGSP (FortiGate Session Sync Protocol) clustering modes.

> **⚠️ AI-Generated Content**: This repository contains AI-generated documentation and examples. Please review and test thoroughly before production use.

## Features

- 🏗️ **Multiple Cluster Types**: Support for FGCP and FGSP clustering
- 🌐 **Multi-Zone Deployment**: Deploy across multiple Availability Zones for high availability
- 🔧 **Flexible Configuration**: Customizable VM sizes, licensing, and network settings
- 🛡️ **Security Focused**: Built-in Network Security Groups and network segmentation
- ⚖️ **Load Balancing**: Integrated External and Internal Load Balancers with floating IP support
- 🏷️ **Consistent Tagging**: Standardized resource tagging for better management
- 🔑 **SSH Key Management**: Automatic SSH key generation and management
- 🔐 **Password Security**: Random password generation for admin accounts
- 🌟 **SD-WAN Ready**: Built-in support for SD-WAN Hub and Spoke configurations
- 🔗 **VPN Connectivity**: Automatic VPN tunnel configuration for SD-WAN deployments
- 📡 **BGP Support**: Dynamic routing with BGP for SD-WAN networks
- 🔄 **Site-to-Site VPN**: Built-in support for IPSec site-to-site tunnels
- 🛣️ **Static Routing**: Configurable static routes for custom network topologies

## What's New in v1.0.6

### 🆕 New Features
- **Site-to-Site VPN Support**: Added comprehensive S2S VPN configuration with `config_s2s` and `s2s_peers` variables
- **Enhanced Load Balancer Options**: Added floating IP support for both external and internal load balancers
- **Static Route Configuration**: New `static_route_cidrs` variable for custom routing
- **Improved NSG Rules**: Enhanced network security group configurations

### 🔧 Improvements
- **FortiGate Version Update**: Default version updated to 7.4.8
- **Variable Organization**: Better structured variables with more configuration options
- **Load Balancer Enhancements**: Configurable backend probe ports and floating IP options
- **Template Addition**: New `fgt_s2s.conf` template for site-to-site VPN configurations

### 🐛 Bug Fixes
- Improved variable validation and default values
- Enhanced module outputs for better integration
- Fixed load balancer configuration dependencies

## Usage

### Basic FGCP Cluster

```hcl
module "fortigate_cluster" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.6"

  prefix   = "my-fgt-cluster"
  location = "East US"
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  fgt_size         = "Standard_F4s"
  license_type     = "payg"
  
  admin_cidr = "10.0.100.0/24"  # Your management network
  
  fgt_vnet = {
    cidr = "10.1.0.0/24"
    subnets = {
      public  = { "name" = "public", "cidr" = "10.1.0.0/26" }
      private = { "name" = "private", "cidr" = "10.1.0.64/26" }
      mgmt    = { "name" = "mgmt", "cidr" = "10.1.0.128/26" }
    }
  }
}
```

### Site-to-Site VPN Configuration

```hcl
module "fortigate_s2s" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.6"

  prefix   = "fgt-s2s-site1"
  location = "East US"
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  license_type     = "payg"
  
  # Enable Site-to-Site VPN
  config_s2s = true
  
  s2s_peers = [{
    id                = "site2"
    remote_gw         = "52.x.x.x"  # Remote site public IP
    local_gw          = ""          # Auto-detected
    bgp_asn_remote    = "65002"
    vpn_port          = "public"
    vpn_cidr          = "10.10.10.0/27"
    vpn_psk           = "your-secure-psk-key"
    vpn_local_ip      = "10.10.10.1"
    vpn_remote_ip     = "10.10.10.2"
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    hck_ip            = "10.10.10.2"
    remote_cidr       = "172.16.0.0/12"
  }]
  
  admin_cidr = "10.100.0.0/16"
  
  fgt_vnet = {
    cidr = "10.1.0.0/24"
    subnets = {
      public  = { "name" = "public", "cidr" = "10.1.0.0/26" }
      private = { "name" = "private", "cidr" = "10.1.0.64/26" }
      mgmt    = { "name" = "mgmt", "cidr" = "10.1.0.128/26" }
    }
  }
}
```

### Enhanced Load Balancer Configuration

```hcl
module "fortigate_fgsp_cluster" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.6"

  prefix   = "my-fgt-fgsp"
  location = "West Europe"
  
  fgt_cluster_type = "fgsp"
  fgt_number       = 4
  fgt_size         = "Standard_F8s"
  license_type     = "byol"
  
  fortiflex_tokens = ["token1", "token2", "token3", "token4"]
  
  admin_cidr = "192.168.1.0/24"
  
  # Enhanced XLB configuration
  config_xlb              = true
  elb_floating_ip_enable  = true
  ilb_floating_ip_enable  = false
  backend_probe_port      = "8008"
  
  fgt_vnet = {
    cidr = "10.2.0.0/23"
    subnets = {
      public  = { "name" = "public", "cidr" = "10.2.0.0/26" }
      private = { "name" = "private", "cidr" = "10.2.0.64/26" }
      mgmt    = { "name" = "mgmt", "cidr" = "10.2.1.0/26" }
    }
  }
  
  # Custom static routes
  static_route_cidrs = ["192.168.0.0/16", "172.16.0.0/12"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix for resource names | `string` | `"fgt-xlb"` | no |
| location | Azure region for deployment | `string` | `"francecentral"` | no |
| resource_group_name | Name of existing resource group | `string` | `null` | no |
| subscription_id | Azure subscription ID | `string` | n/a | yes |
| fgt_cluster_type | Type of FortiGate cluster (fgcp/fgsp) | `string` | `"fgcp"` | no |
| fgt_number | Number of FortiGate instances | `number` | `2` | no |
| fgt_size | Azure VM size for FortiGates | `string` | `"Standard_F4s"` | no |
| fgt_version | FortiGate firmware version | `string` | `"7.4.8"` | no |
| license_type | License type (payg/byol) | `string` | `"payg"` | no |
| config_xlb | Deploy external and internal Load Balancers | `bool` | `true` | no |
| elb_floating_ip_enable | Enable External LB frontend floating IP | `bool` | `false` | no |
| ilb_floating_ip_enable | Enable Internal LB frontend floating IP | `bool` | `false` | no |
| backend_probe_port | Backend probe port for health checks | `string` | `"8008"` | no |
| static_route_cidrs | List of static route CIDRs | `list(string)` | `[]` | no |
| config_s2s | Enable site-to-site VPN configuration | `bool` | `false` | no |
| s2s_peers | List of site-to-site VPN peer configurations | `list(object)` | `[]` | no |
| config_hub | Enable SD-WAN Hub configuration | `bool` | `false` | no |
| config_spoke | Enable SD-WAN Spoke configuration | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| fgt | Complete FortiGate management information |
| api_key | FortiGate API key (sensitive) |
| vnet_id | Azure Virtual Network ID |
| elb_public_ip | External Load Balancer public IP |
| ilb_private_ip | Internal Load Balancer private IP |
| hubs | SD-WAN Hub connection details |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.0 |

For complete documentation, examples, and troubleshooting guide, please visit the [GitHub repository](https://github.com/jmvigueras/azure-fgt-cluster-module).

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) file for details.
