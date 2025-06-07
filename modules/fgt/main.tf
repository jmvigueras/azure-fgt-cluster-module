##############################################################################################################
# FGT ACTIVE VM
##############################################################################################################
resource "azurerm_virtual_machine" "fgt" {
  name                         = "${var.prefix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  network_interface_ids        = var.fgt_ni_ids
  primary_network_interface_id = var.fgt_ni_ids[0]
  vm_size                      = var.size

  lifecycle {
    ignore_changes = [os_profile]
  }

  storage_image_reference {
    publisher = var.publisher
    offer     = var.fgt_offer
    sku       = var.fgt_sku[var.license_type]
    version   = var.fgt_version
  }

  plan {
    publisher = var.publisher
    product   = var.fgt_offer
    name      = var.fgt_sku[var.license_type]
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk-${random_string.random.result}"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option     = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name              = "${var.prefix}-datadisk-${random_string.random.result}"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.prefix}"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.fgt_config
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
}

resource "random_string" "random" {
  length  = 5
  special = false
  numeric = false
  upper   = false
}