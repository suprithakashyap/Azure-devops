variable "vnet_name" { }
variable "location" { }
variable "address_space" { }
variable "subnet_names" {type = "list" }
variable "subnet_prefixes" {type = "list" }
variable "tags" {
  type        = "map"
  default     = {}
}
variable "resgrp_name" { }
variable "out_resgrp_name" {
  default = "dummy"
}


resource "null_resource" "rg_null" {
  triggers = {
    res_name = "${var.out_resgrp_name}"
  }
}


resource "azurerm_virtual_network" "vnet" {
  depends_on = [null_resource.rg_null]
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${var.resgrp_name}"

  tags = "${var.tags}"
}

resource "azurerm_subnet" "subnet" {
  count                = "${length(var.subnet_names)}"
  name                 = "${element(var.subnet_names,count.index)}"
  resource_group_name  = "${var.resgrp_name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${element(var.subnet_prefixes,count.index)}"
  }


resource "azurerm_route_table" "routetable" {
  name                          = "public_rt"
  location                      = "${var.location}"
  resource_group_name           = "${var.resgrp_name}"
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "${var.address_space}"
    next_hop_type  = "vnetlocal"
  }

   route {
    name           = "internetallow"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = "Production"
  }
}


output "out_subnet_id" {
  value = azurerm_subnet.subnet[0].id
}