variable "location" { }
variable "resgrp_name" { }
variable "redis_cache_name" { }
variable "redis_size_capacity" { }
variable "redis_family" { }
variable "redis_sku_name" { }
variable "redis_minimum_tls_version" { }
variable "tags" {
  type        = "map"
  default     = {}
}

variable "out_resgrp_name" {
  default = "dummy"
}

resource "null_resource" "redis_null" {
  triggers = {
    res_name = "${var.out_resgrp_name}"
  }
}

resource "azurerm_redis_cache" "redis_cache" {
  name                = "${var.redis_cache_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resgrp_name}"
  capacity            = "${var.redis_size_capacity}"
  family              = "${var.redis_family}"
  sku_name            = "${var.redis_sku_name}"
  enable_non_ssl_port = false
  minimum_tls_version = "${var.redis_minimum_tls_version}"
  tags                = "${var.tags}"
  redis_configuration {
    maxmemory_policy   = "volatile-lru"
    maxmemory_reserved = 50
    maxfragmentationmemory_reserved = 50
  }
}