variable "resource_grp_name" { }
variable "location" { }
variable "vnet_name" { }
variable "address_space" { }
variable "subnet_names" {type = "list" }
variable "subnet_prefixes" {type = "list" }
variable "security_group_name" {type = "list" }

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.0.0"
  skip_provider_registration = "true"
   features {}

}

terraform {
   backend "azure" {} 
   }

variable "tags" {
  type        = "map"
  default     = {}
}

#storage account vars
variable "storage_account_name" {
  description = "The name for the storage account"
  default     = ""
}
variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium"
  default     = ""
}
variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS and ZRS"
  default     = ""
}
variable "account_kind" {
  description = "Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2"
  default     = ""
}
variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot"
  default     = ""
}



/*
variable "firewall_rule_name" {
  description = "The name of the MySQL Firewall Rule"
  type        = "list"
}
variable "firewall_start_ip" {
  description = "The Start IP Address associated with this Firewall Rule"
  type        = "list"
}
variable "firewall_end_ip" {
  description = "The End IP Address associated with this Firewall Rule"
  type        = "list"
}
variable "vnet_rule_name" {
  description = "The name of the MySQL Virtual Network Rule"
}

variable "data_subnet_name" { }
# Azure Firewall variables

variable "firewall_subnet_name" { }
variable "firewall_public_ip_name" { }
variable "azure_firewall_name" { }
*/

#availability_set vars
variable "availability_set_name" {
  description = "The name of the Availability Set"
  default     = ""
}
variable "fault_domain_count" {
  description = "Specifies the number of fault domains that are used. Defaults to 3"
  default     = 3
}
variable "update_domain_count" {
  description = "Specifies the number of update domains that are used. Defaults to 5"
  default     = 5
}
variable "managed" {
  description = "pecifies whether the availability set is managed or not. Possible values are true or false"
  default     = "true"
}

#vm vars
variable "vm_name" {type = "list" }
variable "vm_size" {type = "list" }
variable "vm_subnet_name" { }
variable "vm_os_version" {
  default     = "latest"
}
variable "username" { }
variable "password" { }
variable "vm_os_simple" {
 default      = "WindowsServer"
}
variable "vm_os_id" {
  default     = ""
}
variable "is_windows_image" {
  default     = "true"
}
variable "nb_instances" {
  default     = "1"
}
variable "data_disk" {
  default     = "false"
}


#Azure Load Balancer variables
variable "lb_public_ip_name" { }
variable "load_balancer_name" { }


module "resource_grp" {
  source = "../Modules/resource_grp"

  resource_grp_name = "${var.resource_grp_name}"
  location = "${var.location}"
  tags = "${var.tags}"
}



module "network" {
  source          = "../Modules/network"
  resgrp_name     = "${module.resource_grp.out_resgrp_name}"
  location        = "${var.location}"
  vnet_name       = "${var.vnet_name}"
  address_space   = "${var.address_space}"
  subnet_names    = "${var.subnet_names}"
  subnet_prefixes = "${var.subnet_prefixes}"
  tags            = "${var.tags}"
  out_resgrp_name = "${module.resource_grp.out_resgrp_name}"
}

module "security_grp" {
  source              = "../Modules/security_grp2"
  security_group_name = "${var.security_group_name}"
  location            = "${var.location}"
  resgrp_name         = "${var.resource_grp_name}"
  subnet_names        = "${var.subnet_names}"
  vnet_name           = "${var.vnet_name}"
  subnet_prefixes     = "${var.subnet_prefixes}"
  tags                = "${var.tags}"
  out_resgrp_name     = "${module.resource_grp.out_resgrp_name}"
  out_subnet_id       = "${module.network.out_subnet_id}"
}

/*
module "azure_firewall" {
  source                  = "../Modules/azure_firewall"
  location                = "${var.location}"
  resgrp_name             = "${var.resource_grp_name}"
  vnet_name               = "${var.vnet_name}"
  firewall_subnet_name    = "${var.firewall_subnet_name}"
  firewall_public_ip_name = "${var.firewall_public_ip_name}"
  azure_firewall_name     = "${var.azure_firewall_name}"
  tags                    = "${var.tags}"
  out_resgrp_name         = "${module.resource_grp.out_resgrp_name}"
  out_subnet_id           = "${module.network.out_subnet_id}"
}
*/

module "availability_set" {
  source                = "/terraform/modules/availability_set"
  availability_set_name = "${var.availability_set_name}"
  location              = "${var.location}"
  resgrp_name           = "${var.resource_grp_name}"
  fault_domain_count    = "${var.fault_domain_count}"
  update_domain_count   = "${var.update_domain_count}"
  managed               = "${var.managed}"
  tags                  = "${var.tags}"
  out_resgrp_name       = "${module.resource_grp.out_resgrp_name}"
}

module "load_balancer" {
  source               = "/terraform/modules/azure_lb"
  lb_public_ip_name    = "${var.lb_public_ip_name}"
  location             = "${var.location}"
  resgrp_name          = "${var.resource_grp_name}"
  load_balancer_name   = "${var.load_balancer_name}"
  nb_instances         = "${var.nb_instances}"
  tags                 = "${var.tags}"
  out_resgrp_name      = "${module.resource_grp.out_resgrp_name}"
}

module "compute_windows" {
  source               = "/terraform/modules/compute_windows"
  vm_name              = "${var.vm_name}"
  resgrp_name          = "${var.resource_grp_name}"
  location             = "${var.location}"
  vnet_name            = "${var.vnet_name}"
  vm_size              = "${var.vm_size}"
  vm_subnet_name       = "${var.vm_subnet_name}"
  username             = "${var.username}"
  password             = "${var.password}"
  nb_instances         = "${var.nb_instances}"
  tags                 = "${var.tags}"
  lb_nat_rule_id       = "${module.load_balancer.lb_nat_rule_id}"
  lb_backend_pool_id   = "${module.load_balancer.lb_backend_pool_id}"
  availability_set_id  = "${module.availability_set.availability_set_id}"
  out_subnet_id        = "${module.network.out_subnet_id}"
  out_resgrp_name      = "${module.resource_grp.out_resgrp_name}"
}

module "storage_account" {
  source                    = "../Modules/storage_account"
  storage_account_name      = "${var.storage_account_name}"
  resgrp_name               = "${var.resource_grp_name}"
  location                  = "${var.location}"
  account_tier              = "${var.account_tier}"
  account_replication_type  = "${var.account_replication_type}"
  account_kind              = "${var.account_kind}"
  access_tier               = "${var.access_tier}"
  tags                      = "${var.tags}"
  out_resgrp_name           = "${module.resource_grp.out_resgrp_name}"
}
