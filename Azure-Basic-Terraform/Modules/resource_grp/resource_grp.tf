variable "resource_grp_name" { }
variable "location" { }
variable "tags" {
  type        = "map"
  default     = {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_grp_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}

output "out_resgrp_name" {
  value = "${azurerm_resource_group.rg.name}"
}