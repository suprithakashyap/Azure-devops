# Common variables
variable "location" { }
variable "resource_grp_name" { }
variable "tags" {
  type        = "map"
  default     = {}
}

# CDN Profile variables
variable "cdn_profile_name" { }
variable "sku_pricing_tier" { }

# CND Endpoint variables
variable "cdn_endpoint_name" { }
variable "cdn_origin_name" { }
variable "origin_server_host_name" { }


resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "${var.cdn_profile_name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_grp_name}"
  sku                 = "${var.sku_pricing_tier}"
  tags                = "${var.tags}"
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  name                = "${var.cdn_endpoint_name}"
  profile_name        = "${azurerm_cdn_profile.cdn_profile.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_grp_name}"
  is_http_allowed     = true
  is_https_allowed    = true
  tags                = "${var.tags}"

  origin {
    name      = "${var.cdn_origin_name}"
    host_name = "${var.origin_server_host_name}"
    http_port = 80
    https_port = 443
  }
}