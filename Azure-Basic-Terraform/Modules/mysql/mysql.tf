resource "null_resource" "mysql_null" {
  triggers = {
    res_name            = "${var.out_resgrp_name}"
    out_subnet_id       = "${var.out_subnet_id}"
  }
}

data "azurerm_subnet" "subnet" {
  depends_on = [null_resource.mysql_null]
  name                 = "${var.subnet_name}"
  virtual_network_name = "${var.vnet_name}"
  resource_group_name  = "${var.resgrp_name}"
}

resource "azurerm_mysql_server" "mysql" {
  depends_on = [null_resource.mysql_null]
  name                = "${var.mysql_server_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  tags                = "${var.tags}"
  sku {
    name     = "${var.sku_name}"
    capacity = "${var.mysql_vcores}"
    tier     = "${var.mysql_tier}"
    family   = "${var.mysql_family}"
  }

  storage_profile {
    storage_mb            = "${var.storage_size}"
    backup_retention_days = "${var.backup_retention_days}"
    geo_redundant_backup  = "${var.geo_redundant_backup}"
  }

  administrator_login          = "${var.server_username}"
  administrator_login_password = "${var.server_password}"
  version                      = "${var.mysql_version}"
  ssl_enforcement              = "${var.ssl_enforcement}"
}

/*resource "azurerm_mysql_firewall_rule" "firewallrule" {
  count               = "${length(var.firewall_rule_name)}"
  name                = "${element(var.firewall_rule_name,count.index)}"
  resource_group_name = "${var.resgrp_name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  start_ip_address    = "${element(var.start_ip,count.index)}"
  end_ip_address      = "${element(var.end_ip,count.index)}"
}

resource "azurerm_mysql_virtual_network_rule" "networkrule" {
  name                = "${var.vnet_rule_name}"
  resource_group_name = "${var.resgrp_name}"
  server_name         = "${azurerm_mysql_server.mysql.name}"
  subnet_id           = "${data.azurerm_subnet.subnet.id}"
}*/