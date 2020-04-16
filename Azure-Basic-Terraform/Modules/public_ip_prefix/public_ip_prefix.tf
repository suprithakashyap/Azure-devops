variable "public_ip_prefix_name" { }
variable "location" { }
variable "resgrp_name" { }
variable "prefix_length" { }
variable "tags" {
  type        = "map"
  default     = {}
}


resource "azurerm_public_ip_prefix" "pub_ip_prefix" {
  name                = "${var.public_ip_prefix_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"

  prefix_length = "${var.prefix_length}"

  tags = "${var.tags}"
}