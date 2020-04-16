resource "null_resource" "as_null" {
  triggers = {
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_availability_set" "availability_set" {
  name                         = "${var.availability_set_name}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resgrp_name}"
  platform_fault_domain_count  = "${var.fault_domain_count}"
  platform_update_domain_count = "${var.update_domain_count}"
  managed                      = "${var.managed}"
  tags = "${var.tags}"
}

output "availability_set_id" {
  value = "${azurerm_availability_set.availability_set.id}"
}