variable "security_group_name" {type = "list" }
variable "location" { }
variable "resgrp_name" { }
variable "tags" {
  type        = "map"
  default     = {}
}

resource "azurerm_network_security_group" "nsg" {
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
    source_address_prefix      = "*"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description            = "Http Port"
  }
  tags                = "${var.tags}"
}


output "nsg_id" {
  value = azurerm_network_security_group.nsg[0].id
}