variable "lb_public_ip_name" { }
variable "location" { }
variable "resgrp_name" { }
variable "load_balancer_name" { }
variable "nb_instances" { }
variable "tags" {
  type        = "map"
  default     = {}
}

variable "out_resgrp_name" {
  default = "dummy"
}

resource "null_resource" "lb_null" {
  triggers = {
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_public_ip" "lb_public_ip" {
  depends_on = [null_resource.lb_null]
  name                = "${var.lb_public_ip_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  allocation_method   = "Static"
}

resource "azurerm_lb" "load_balancer" {
  name                = "${var.load_balancer_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  tags                = "${var.tags}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lb_public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${var.resgrp_name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "BackendPool"
}


resource "azurerm_lb_nat_rule" "tcp" {
  resource_group_name            = "${var.resgrp_name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "RDP-VM-${count.index}"
  protocol                       = "tcp"
  frontend_port                  = "5000${count.index + 1}"
  backend_port                   = 3389
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  count                          = "${var.nb_instances}"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${var.resgrp_name}"
  loadbalancer_id                = "${azurerm_lb.load_balancer.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${var.resgrp_name}"
  loadbalancer_id     = "${azurerm_lb.load_balancer.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

output "lb_backend_pool_id" {
  value = azurerm_lb_backend_address_pool.backend_pool.id
}

output "lb_nat_rule_id" {
  value = azurerm_lb_nat_rule.tcp.*.id
}