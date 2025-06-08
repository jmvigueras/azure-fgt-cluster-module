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
- ⚖️ **Load Balancing**: Integrated External and Internal Load Balancers
- 🏷️ **Consistent Tagging**: Standardized resource tagging for better management
- 🔑 **SSH Key Management**: Automatic SSH key generation and management
- 🔐 **Password Security**: Random password generation for admin accounts
- 🌟 **SD-WAN Ready**: Built-in support for SD-WAN Hub and Spoke configurations
- 🔗 **VPN Connectivity**: Automatic VPN tunnel configuration for SD-WAN deployments
- 📡 **BGP Support**: Dynamic routing with BGP for SD-WAN networks

## Architecture

This module creates a complete FortiGate cluster infrastructure including:

- Virtual Network (VNet) with public, private, and management subnets
- FortiGate VMs configured in FGCP or FGSP mode
- Network Security Groups with appropriate rules
- Network interfaces and routing configurations
- External and Internal Load Balancers
- Public IP addresses for management and external access
- SSH key pairs for secure access

## Usage

### Basic FGCP Cluster

```hcl
module "fortigate_cluster" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

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

### FGSP Cluster for High Performance

```hcl
module "fortigate_fgsp_cluster" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

  prefix   = "my-fgt-fgsp"
  location = "West Europe"
  
  fgt_cluster_type = "fgsp"
  fgt_number       = 4
  fgt_size         = "Standard_F8s"
  license_type     = "byol"
  
  fortiflex_tokens = ["token1", "token2", "token3", "token4"]
  
  admin_cidr = "192.168.1.0/24"
  
  fgt_vnet = {
    cidr = "10.2.0.0/23"
    subnets = {
      public  = { "name" = "public", "cidr" = "10.2.0.0/26" }
      private = { "name" = "private", "cidr" = "10.2.0.64/26" }
      mgmt    = { "name" = "mgmt", "cidr" = "10.2.1.0/26" }
    }
  }
}
```

### Enterprise Deployment with Custom Resource Group

### SD-WAN Hub Configuration

```hcl
module "fortigate_sdwan_hub" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

  prefix   = "sdwan-hub"
  location = "Central US"
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  license_type     = "byol"
  
  # Enable SD-WAN Hub functionality
  config_hub = true
  
  hub = [{
    id                = "HUB-CENTRAL"
    bgp_asn_hub       = "65001"
    vpn_cidr          = "172.16.100.0/24"
    vpn_psk           = "your-secure-psk-key"
    cidr              = "10.0.0.0/8"
    vpn_port          = "public"
  }]
  
  admin_cidr = "10.100.0.0/16"
}
```

### SD-WAN Spoke Configuration

```hcl
module "fortigate_sdwan_spoke" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

  prefix   = "sdwan-spoke-east"
  location = "East US"
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  license_type     = "payg"
  
  # Enable SD-WAN Spoke functionality
  config_spoke = true
  
  spoke = {
    id      = "SPOKE-EAST"
    cidr    = "10.1.0.0/24"
    bgp_asn = "65002"
  }
  
  # Hub connection details
  hubs = [{
    id                = "HUB-CENTRAL"
    bgp_asn           = "65001"
    external_ip       = "52.x.x.x"  # Hub public IP
    hub_ip            = "172.16.100.1"
    site_ip           = "172.16.100.10"
    hck_ip            = "172.16.100.1"
    vpn_psk           = "your-secure-psk-key"
    cidr              = "10.0.0.0/8"
    ike_version       = "2"
    network_id        = "1"
    dpd_retryinterval = "5"
    sdwan_port        = "public"
  }]
  
  admin_cidr = "10.100.0.0/16"
}
```

```hcl
# Create custom resource group
resource "azurerm_resource_group" "fgt_rg" {
  name     = "fgt-production-rg"
  location = "North Europe"
  
  tags = {
    Environment = "Production"
    Project     = "Security Infrastructure"
  }
}

module "fortigate_enterprise" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

  prefix              = "prod-fgt"
  location            = azurerm_resource_group.fgt_rg.location
  resource_group_name = azurerm_resource_group.fgt_rg.name
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  fgt_size         = "Standard_F16s"
  fgt_version      = "7.4.7"
  license_type     = "byol"
  
  admin_username = "fortiadmin"
  admin_cidr     = "10.100.0.0/16"
  admin_port     = "8443"
  
  config_pip_mgmt   = true
  config_pip_public = true
  
  tags = {
    Environment = "Production"
    CostCenter  = "Security"
    Compliance  = "Required"
  }
}
```

## Cluster Types

### FGCP (FortiGate Clustering Protocol)
- **Members**: 2 FortiGates only
- **Deployment**: Active-Passive configuration
- **Use Case**: High availability with automatic failover
- **Sync**: Configuration and session synchronization
- **Best For**: Traditional HA deployments

### FGSP (FortiGate Session Sync Protocol)
- **Members**: 2-16 FortiGates (recommended: ≤8)
- **Deployment**: Active-Active configuration
- **Use Case**: Load balancing and horizontal scaling
- **Sync**: Session synchronization only
- **Best For**: High-throughput environments

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0 |
| tls | >= 3.0 |
| random | >= 3.0 |
| local | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| prefix | Prefix for resource names | `string` | `"fgt-xlb"` | no |
| location | Azure region for deployment | `string` | `"francecentral"` | no |
| resource_group_name | Name of existing resource group (creates new if null) | `string` | `null` | no |
| subscription_id | Azure subscription ID | `string` | n/a | yes |
| fgt_cluster_type | Type of FortiGate cluster (fgcp/fgsp) | `string` | `"fgcp"` | no |
| fgt_number | Number of FortiGate instances | `number` | `2` | no |
| fgt_size | Azure VM size for FortiGates | `string` | `"Standard_F4s"` | no |
| fgt_version | FortiGate firmware version | `string` | `"7.4.7"` | no |
| license_type | License type (payg/byol) | `string` | `"payg"` | no |
| fortiflex_tokens | List of FortiFlex license tokens | `list(string)` | `[]` | no |
| admin_username | Admin username for FortiGates | `string` | `"azureadmin"` | no |
| admin_password | Admin password (auto-generated if null) | `string` | `null` | no |
| admin_cidr | CIDR block allowed for management access | `string` | `"0.0.0.0/0"` | no |
| admin_port | Admin port for FortiGate management | `string` | `"8443"` | no |
| fgt_vnet | VNet configuration object | `object` | See example | no |
| config_pip_mgmt | Create public IP for management | `bool` | `true` | no |
| config_pip_public | Create public IP for public interface | `bool` | `true` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| config_hub | Enable SD-WAN Hub configuration | `bool` | `false` | no |
| config_spoke | Enable SD-WAN Spoke configuration | `bool` | `false` | no |
| hub | SD-WAN Hub configuration parameters | `list(object)` | `[]` | no |
| spoke | SD-WAN Spoke configuration parameters | `object` | See example | no |
| hubs | List of Hub connection details for Spokes | `list(object)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| fgt | Complete FortiGate management information including admin credentials and URLs |
| api_key | FortiGate API key for programmatic access |
| vnet_id | Azure Virtual Network ID |
| vnet_name | Azure Virtual Network name || subnet_cidrs | CIDR blocks of all subnets |
| subnet_ids | IDs of all subnets |
| fgt_nic_ids_list | List of FortiGate network interface IDs |
| fgt_nic_ips_map | Map of FortiGate network interface IP addresses |
| fgt_ports_config_map | Port configuration mapping for FortiGates |
| hubs | SD-WAN Hub connection details for Spoke configuration |

## Azure VM Sizes

| VM Size | vCPUs | RAM (GB) | Network Performance | Use Case |
|---------|-------|----------|-------------------|----------|
| Standard_F2s | 2 | 4 | Moderate | Development/Testing |
| Standard_F4s | 4 | 8 | High | Small Production |
| Standard_F8s | 8 | 16 | High | Medium Production |
| Standard_F16s | 16 | 32 | Extremely High | Large Production |
| Standard_F32s | 32 | 64 | Extremely High | Enterprise |

## Security Considerations

- **Network Segmentation**: Separate subnets for public, private, and management traffic
- **NSG Rules**: Restrictive Network Security Group rules
- **Admin Access**: Configurable admin CIDR for management access control
- **SSH Keys**: Automatically generated SSH key pairs
- **Password Management**: Secure random password generation
- **Public IP Control**: Optional public IP assignment

## Cost Optimization

- **VM Sizing**: Choose appropriate VM sizes based on throughput requirements
- **Licensing**: Consider PAYG vs BYOL based on usage patterns
- **Public IPs**: Disable unnecessary public IP assignments
- **Load Balancers**: Standard SKU provides better performance but higher cost
- **Storage**: Use managed disks for better performance and reliability

## Deployment Guide

1. **Prerequisites**:
   ```bash
   # Azure CLI login
   az login
   az account set --subscription "your-subscription-id"
   
   # Terraform setup
   terraform --version  # Ensure >= 1.0
   ```

2. **Basic Deployment**:
   ```bash
   # Clone repository
   git clone https://github.com/jmvigueras/azure-fgt-cluster-module.git
   cd azure-fgt-cluster-module
   
   # Initialize and deploy
   terraform init
   terraform plan -var="subscription_id=your-subscription-id"
   terraform apply
   ```

3. **Access FortiGates**:
   ```bash
   # Get configuration details
   terraform output fgt_config
   
   # SSH access (if enabled)
   ssh -i ./ssh-key/fgt-xlb-ssh-key.pem azureadmin@<public-ip>
   ```

## Examples

### Quick Start Example

```hcl
# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Deploy basic FGCP cluster
module "fortigate_cluster" {
  source = "github.com/jmvigueras/azure-fgt-cluster-module?ref=v1.0.3"

  subscription_id = var.subscription_id
  prefix          = "demo-fgt"
  location        = "East US"
  
  fgt_cluster_type = "fgcp"
  fgt_number       = 2
  license_type     = "payg"
  
  admin_cidr = "YOUR_IP/32"  # Replace with your public IP
}

# variables.tf
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

# outputs.tf
output "fortigate_management" {
  description = "FortiGate management information"
  value       = module.fortigate_cluster.fgt
}

output "fortigate_hubs" {
  description = "SD-WAN Hub information for Spoke connectivity"
  value       = module.fortigate_cluster.hubs
  sensitive   = true
}

output "network_details" {
  description = "Network configuration details"
  value = {
    subnet_ids   = module.fortigate_cluster.subnet_ids
    subnet_cidrs = module.fortigate_cluster.subnet_cidrs
  }
}  description = "External Load Balancer IP"
  value       = module.fortigate_cluster.subnet_ids
}
```

### Deployment Commands

```bash
# 1. Set your Azure subscription
export TF_VAR_subscription_id="your-subscription-id-here"

# 2. Initialize and deploy
terraform init
terraform plan
terraform apply

# 3. Get outputs

# 4. Access FortiGate management interfaces
terraform output fgt
# Output example:
# {
#   "admin" = "azureadmin"
#   "fgt_1" = "https://52.x.x.x:8443"
#   "fgt_2" = "https://52.y.y.y:8443"
#   "pass" = "RandomGeneratedPassword123!"
# }terraform output
```

### Advanced Examples

For more comprehensive examples, see the module source code and configuration options above.

## Troubleshooting

### Common Issues

1. **VM Size Not Available**:
   ```bash
   # Check available VM sizes in region
   az vm list-sizes --location "East US" --output table
   ```

2. **Quota Exceeded**:
   ```bash
   # Check current quotas
   az vm list-usage --location "East US" --output table
   ```

3. **Network Connectivity**:
   - Verify NSG rules allow required traffic
   - Check route tables for proper routing
   - Ensure subnet CIDR blocks don't overlap

4. **FortiGate Not Responding**:
   - Check VM status in Azure portal
   - Verify boot diagnostics
   - Review FortiGate logs via serial console

## Support

This is a community module maintained by [jmvigueras](https://github.com/jmvigueras).

### Reporting Issues
Please report issues, bugs, and feature requests via [GitHub Issues](https://github.com/jmvigueras/azure-fgt-cluster-module/issues).

### Contributing
Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This module is licensed under the Apache License 2.0. See [LICENSE](LICENSE) file for details.

## Disclaimer

This module is provided as-is for educational and testing purposes. Users are responsible for:
- Understanding Azure costs associated with deployed resources
- Ensuring compliance with security requirements
- Testing thoroughly before production deployment
- Maintaining and updating the infrastructure appropriately

**🤖 AI-Generated Content Notice**: Parts of this repository, including documentation, examples, and code comments, have been generated or enhanced using AI agents. While efforts have been made to ensure accuracy and best practices, this content may contain errors, outdated information, or suboptimal configurations. Users should:

- Thoroughly review and test all code before production use
- Validate configurations against current Azure and Fortinet best practices
- Verify compatibility with your specific requirements and environment
- Report any issues or improvements via GitHub Issues

Please use this module as a starting point and adapt it to your specific needs with proper testing and validation.

**⚠️ Important**: Azure resources created by this module will incur costs. Please review Azure pricing and clean up resources when no longer needed.

---

## Acknowledgments

- [Fortinet](https://www.fortinet.com/) for FortiGate documentation and best practices
- [Microsoft Azure](https://azure.microsoft.com/) for cloud infrastructure and services
- Terraform community for modules and best practices
