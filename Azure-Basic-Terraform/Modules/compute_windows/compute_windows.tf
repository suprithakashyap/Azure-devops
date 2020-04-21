variable "vm_name" {type = "list" }
variable "resgrp_name" { }
variable "location" { }
variable "vm_size" {type = "list" }

variable "vnet_name" { }
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
variable "vm_os_simple" {
  default     = "WindowsServer"
}
variable "vm_os_id" {
  default     = ""
}
variable "is_windows_image" {
  default     = "true"
}
variable "nb_instances" {
  default     = "1"
}

variable "data_disk" {
  default     = "false"
}

variable "tags" {
  type        = "map"
  default     = {}
}
variable "vm_subnet_name" { }
variable "out_subnet_id" {
  default    = "dummy"
}
variable "out_resgrp_name" {
  default    = "dummy"
}
variable "availability_set_id" {
  default    = "dummy"
}
variable "lb_backend_pool_id" {
  default     = "dummy"
}
variable "lb_nat_rule_id" {
  default    = "dummy"
}

resource "null_resource" "subnet_null" {
  triggers = {
    res_name            = "${var.out_resgrp_name}"
    out_subnet_id       = "${var.out_subnet_id}"
    #availability_set_id = "${var.availability_set_id}"
    lb_backend_pool_id  = "${var.lb_backend_pool_id}"
  }
}


module "os" {
  source       = "../os"
  vm_os_simple = "${var.vm_os_simple}"
}


data "azurerm_subnet" "subnet" {
  depends_on = [null_resource.subnet_null]
  name                 = "${var.vm_subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.resgrp_name}"
}

resource "azurerm_public_ip" "example" {
  name                    = "${element(var.vm_name,count.index)}" 
  count                   = "${var.nb_instances}"
  location                = "${var.location}"
  resource_group_name     = "${var.resgrp_name}"
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30
  

  tags = {
    environment = "test"
  }
}



resource "azurerm_network_interface" "nic" {
  depends_on = [null_resource.subnet_null]
  count               = "${var.nb_instances}"
  name                = "${element(var.vm_name,count.index)}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"

  ip_configuration {
    name                          = "ip"
    subnet_id                     = "${data.azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = "${element(azurerm_public_ip.example.*.id,count.index)}"
    #load_balancer_backend_address_pools_ids = ["${var.lb_backend_pool_id}"]
    #load_balancer_inbound_nat_rules_ids     = ["${element(var.lb_nat_rule_id, count.index)}"]
  }
}


resource "azurerm_network_interface_backend_address_pool_association" "example" {
  network_interface_id    = azurerm_network_interface.nic.0.id
  ip_configuration_name   = "ip"
  backend_address_pool_id = "${var.lb_backend_pool_id}"
}


resource "azurerm_virtual_machine" "windows_vm" {
  count = "${(((var.vm_os_id != "" && var.is_windows_image == "true") || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) && var.data_disk == "false") ? var.nb_instances : 0}"
  name                  = "${element(var.vm_name,count.index)}"
  location              = "${var.location}"
  resource_group_name   = "${var.resgrp_name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id,count.index)}"]
  vm_size               = "${element(var.vm_size,count.index)}"
  #availability_set_id   = "${var.availability_set_id}"
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
    name              = "${element(var.vm_name,count.index)}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "${element(var.vm_name,count.index)}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }
  os_profile_windows_config {}

  tags = "${var.tags}"


}
