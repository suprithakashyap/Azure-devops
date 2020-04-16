variable "location" { }
variable "resgrp_name" { }

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "imfdemoapp"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    java_container  =   "TOMCAT"
    java_version    =    1.8
    java_container_version  =  8.5
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}