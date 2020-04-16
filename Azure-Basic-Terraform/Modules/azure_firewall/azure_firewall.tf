variable "location" { }
variable "resgrp_name" { }
variable "vnet_name" { }
variable "firewall_subnet_name" { }
variable "firewall_public_ip_name" { }
variable "azure_firewall_name" { }
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

resource "null_resource" "firewall_null" {
  triggers = {
    sub_id   = "${var.out_subnet_id}"
    res_name = "${var.out_resgrp_name}"
  }
}

data "azurerm_subnet" "firewall_subnet" {
  depends_on = [null_resource.firewall_null]
  name                 = "${var.firewall_subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.resgrp_name}"
}

resource "azurerm_public_ip" "firewall_pub_ip" {
  name                = "${var.firewall_public_ip_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "azure_firewall" {
  name                = "${var.azure_firewall_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  tags                = "${var.tags}"

  ip_configuration {
    name                 = "firewall_ip"
    subnet_id            = "${data.azurerm_subnet.firewall_subnet.id}"
    public_ip_address_id = "${azurerm_public_ip.firewall_pub_ip.id}"
  }
}