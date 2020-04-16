variable "vm_name" { }
variable "location" { }
variable "resource_grp_name" { }
variable "environment" { }
variable "vm_size" { }
variable "subnet_name" { }
variable "vnet_name" { }
variable "private_ip" { }
variable "vm_os_publisher" {
  default = ""
}
variable "vm_os_offer" {
  default = ""
}
variable "vm_os_sku" {
  default = ""
}
variable "vm_os_version" {
  default     = "latest"
}
variable "username" { }
variable "password" { }
variable "vm_os_simple" { }
variable "vm_os_id" {
  default     = ""
}
variable "is_windows_image" {
  default     = "false"
}
variable "nb_instances" {
  default     = "1"
}

variable "data_disk" {
  default     = "false"
}

module "os" {
  source       = "../Modules/os"
  vm_os_simple = "${var.vm_os_simple}"
}


data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.resource_grp_name}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_grp_name}"

  ip_configuration {
    name                          = "ip"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.private_ip}"
  }
}

resource "azurerm_virtual_machine" "linux_vm" {
  count = "${!contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer") && var.is_windows_image != "true" && var.data_disk == "false" ? var.nb_instances : 0}"
  name                  = "${var.vm_name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_grp_name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.vm_size}"

  delete_os_disk_on_termination = true


  # delete_data_disks_on_termination = true

  storage_image_reference {
    id        = "${var.vm_os_id}"
    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }
  storage_os_disk {
    name              = "${var.vm_name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "${var.vm_name}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "${var.environment}"
  }
}