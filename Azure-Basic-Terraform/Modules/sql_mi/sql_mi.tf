variable "resgrp_name" { }
variable "location" { }
variable "vnet_name" { }
variable "data_subnet_Prefix" { }
variable "data_subnet_routetable_name" {

}

variable "data_subnet_name" {
}

variable "sql_managed_instance_name" {
}


variable "managed_instance_administratorLogin" {
}

variable "managed_instance_administratorLoginPassword" {
}

variable "managed_instance_database" {
}

variable "sqlManagedInstance_skuName" { }
variable "sqlManagedInstance_skuEdition" { }
variable "sqlManagedInstance_hardwareFamily" { }
variable "sqlManagedInstance_licenseType" { }
variable "sqlManagedInstance_vCores" { }
variable "sqlManagedInstance_storageSizeInGB" { }
variable "data_subnet_nsg_name" { }


variable "out_subnet_id" {
  default = "dummy"
}
variable "out_resgrp_name" {
  default = "dummy"
}

resource "null_resource" "sqlmi_null" {
  triggers = {
    res_name            = "${var.out_resgrp_name}"
    out_subnet_id       = "${var.out_subnet_id}"
  }
}

resource "azurerm_template_deployment" "nsg-with-rules" {
      name                = "nsg-with-rules"
      resource_group_name = "${var.resgrp_name}"
      template_body       = "${file("/terraform/modules/sql_mi/nsg_arm_template/azuredeploy.json")}"
      parameters={
        network_security_group_name = "${var.data_subnet_nsg_name}"
                location                    = "${var.location}"
                data_subnet_Prefix          = "${var.data_subnet_Prefix}"
      }
      deployment_mode = "Incremental"
}

resource "azurerm_template_deployment" "routing-table-with-routes" {
      depends_on = [null_resource.sqlmi_null]
      name                = "${var.sql_managed_instance_name}-rt"
      resource_group_name = "${var.resgrp_name}"
      template_body       = "${file("/terraform/modules/sql_mi/route_table_arm_template/azuredeploy.json")}"
       parameters={
        route_table_name    ="${var.data_subnet_routetable_name}"
        data_subnet_Prefix  = "${var.data_subnet_Prefix}"
        location            = "${var.location}"
      }
      deployment_mode = "Incremental"
}

data "azurerm_route_table" "route_table" {
  name                = "${var.data_subnet_routetable_name}"
  resource_group_name = "${var.resgrp_name}"
  depends_on = [azurerm_template_deployment.routing-table-with-routes]
}

data "azurerm_subnet" "data_subnet" {
  name                 = "${var.data_subnet_name}"
  resource_group_name  = "${var.resgrp_name}"
  virtual_network_name = "${var.vnet_name}"
  depends_on = [azurerm_template_deployment.routing-table-with-routes]
}

data "azurerm_network_security_group" "nsg" {
  name                 = "${var.data_subnet_nsg_name}"
  resource_group_name  = "${var.resgrp_name}"
  depends_on = [azurerm_template_deployment.nsg-with-rules]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = "${data.azurerm_subnet.data_subnet.id}"
  network_security_group_id = "${data.azurerm_network_security_group.nsg.id}"
  depends_on = [azurerm_template_deployment.nsg-with-rules]
}

resource "azurerm_subnet_route_table_association" "association" {
  subnet_id      = "${data.azurerm_subnet.data_subnet.id}"
  route_table_id = "${data.azurerm_route_table.route_table.id}"
  depends_on = [azurerm_template_deployment.routing-table-with-routes]
}


resource "azurerm_template_deployment" "sql-managed-instance" {
      name                = "${var.sql_managed_instance_name}-mi"
      resource_group_name = "${var.resgrp_name}"
      template_body = "${file("/terraform/modules/sql_mi/SQL_MI_arm_template/azuredeploy.json")}"
      parameters={
        managed_instance_name                       = "${var.sql_managed_instance_name}"
        managed_instance_administratorLogin         = "${var.managed_instance_administratorLogin}"
        managed_instance_administratorLoginPassword = "${var.managed_instance_administratorLoginPassword}"
        managed_instance_database                   = "${var.managed_instance_database}"
        sqlManagedInstance_skuName                  = "${var.sqlManagedInstance_skuName}"
        sqlManagedInstance_skuEdition               = "${var.sqlManagedInstance_skuEdition}"
        sqlManagedInstance_hardwareFamily           = "${var.sqlManagedInstance_hardwareFamily}"
        sqlManagedInstance_licenseType              = "${var.sqlManagedInstance_licenseType}"
        sqlManagedInstance_vCores                   = "${var.sqlManagedInstance_vCores}"
        sqlManagedInstance_storageSizeInGB          = "${var.sqlManagedInstance_storageSizeInGB}"
        data_subnet_id                              = "${data.azurerm_subnet.data_subnet.id}"
      }
      deployment_mode = "Incremental"
      depends_on=[azurerm_subnet_route_table_association.association]
}