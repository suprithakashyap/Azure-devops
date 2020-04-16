variable "appgw_public_ip_name" { }
variable "app_gateway_name" { }
variable "resource_group_name" { }
variable "location" { }
variable "appgw_sku_name" { }
variable "appgw_tier" { }
variable "appgw_capacity" { }
variable "appgw_frontend_port_name" { }
variable "appgw_frontend_port" { }
variable "backend_http_port" { }
variable "backend_http_protocol" { }
variable "backend_http_request_timeout" { }
variable "request_routing_rule_type" { }

variable "app_subnet_name" { }
variable "vnet_name" { }

data "azurerm_subnet" "app_subnet" {
  name                 = "${var.app_subnet_name}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${var.vnet_name}"
}

resource "azurerm_public_ip" "appgw_pub_ip" {
  name                = "${var.appgw_public_ip_name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = "${var.app_gateway_name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"

  sku {
    name     = "${var.appgw_sku_name}"
    tier     = "${var.appgw_tier}"
    capacity = "${var.appgw_capacity}"
  }

  gateway_ip_configuration {
    name      = "${var.app_gateway_name}-gw-ip-config"
    subnet_id = "${data.azurerm_subnet.app_subnet.id}"
  }

  frontend_port {
    name = "${var.appgw_frontend_port_name}"
    port = "${var.appgw_frontend_port}"
  }

  frontend_ip_configuration {
    name                 = "${var.app_gateway_name}-frontend-ip-config"
    public_ip_address_id = "${azurerm_public_ip.appgw_pub_ip.id}"
  }

  backend_address_pool {
    name = "${var.app_gateway_name}-backend-pool"
  }

  backend_http_settings {
    name                  = "${var.app_gateway_name}-backend-http"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = "${var.backend_http_port}"
    protocol              = "${var.backend_http_protocol}"
    request_timeout       = "${var.backend_http_request_timeout}"
  }

  http_listener {
    name                           = "${var.app_gateway_name}-http-listener"
    frontend_ip_configuration_name = "${var.app_gateway_name}-frontend-ip-config"
    frontend_port_name             = "${var.appgw_frontend_port_name}"
    protocol                       = "${var.backend_http_protocol}"
  }

  request_routing_rule {
    name                       = "${var.app_gateway_name}-rule"
    rule_type                  = "${var.request_routing_rule_type}"
    http_listener_name         = "${var.app_gateway_name}-http-listener"
    backend_address_pool_name  = "${var.app_gateway_name}-backend-pool"
    backend_http_settings_name = "${var.app_gateway_name}-backend-http"
  }
}