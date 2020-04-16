resource "null_resource" "storage_null" {
  triggers = {
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_storage_account" "test" {
  depends_on               = [null_resource.storage_null]
  name                     = "${var.storage_account_name}"
  resource_group_name      = "${var.resgrp_name}"
  location                 = "${var.location}"
  account_tier             = "${var.account_tier}"
  account_replication_type = "${var.account_replication_type}"
  account_kind             = "${var.account_kind}"
  access_tier              = "${var.access_tier}"

  tags = "${var.tags}"
}