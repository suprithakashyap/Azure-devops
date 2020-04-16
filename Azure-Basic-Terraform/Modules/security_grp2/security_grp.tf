variable "security_group_name" {type = "list" }
variable "location" { }
variable "resgrp_name" { }
variable "subnet_names" { }
variable "vnet_name" { }
variable "subnet_prefixes" { }
variable "tags" {
  type        = "map"
  default     = {}
}

variable "out_resgrp_name" {
  default = "dummy"
}
variable "out_subnet_id" {
  default = "dummy"
}

resource "null_resource" "security_null" {
  triggers = {
    sub_id   = "${var.out_subnet_id}"
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_network_security_group" "nsg" {
  depends_on = [null_resource.security_null]
  count               = "${length(var.security_group_name)}"
  name                = "${element(var.security_group_name,count.index)}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  security_rule {
    name                       = "Port_3389"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${var.subnet_prefixes[0]}"
    destination_address_prefix = "*"
    description            = "RDP Access from Whitelisted IPs to bastion host"
  }
  security_rule {
    name                       = "Port_80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.subnet_prefixes[0]}"
    destination_address_prefix = "${var.subnet_prefixes[1]}"
    description            = "Dev web-app http port"
  }
  tags                = "${var.tags}"
}
data "azurerm_subnet" "subnet" {
  depends_on = [azurerm_network_security_group.nsg]
  count                = "${length(var.subnet_names)}"
  name                 = "${element(var.subnet_names,count.index)}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.resgrp_name}"
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  count                     = "${length(var.security_group_name)}"
  subnet_id                 = "${element(data.azurerm_subnet.subnet.*.id,count.index)}"
  network_security_group_id = "${element(azurerm_network_security_group.nsg.*.id,count.index)}"
}