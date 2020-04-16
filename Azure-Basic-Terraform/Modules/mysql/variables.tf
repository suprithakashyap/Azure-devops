variable "mysql_server_name" {
  description = "The name of the MySQL server"
}

variable "location" {
  description = "The location where the MySQL server needs to be created"
}

variable "resgrp_name" {
  description = "The Resource Group name in which MySQL server needs to be created"
}

variable "sku_name" {
  description = "Specifies the SKU Name for this MySQL Server. The name of the SKU, follows the tier + family + cores pattern (e.g. B_Gen4_1, GP_Gen5_8)"
  default     = "GP_Gen5_2"
}

variable "mysql_vcores" {
  description = "The number of cores for the server"
  default     = "2"
}

variable "mysql_tier" {
  description = "The tier of the particular SKU. Possible values are Basic, GeneralPurpose, and MemoryOptimized"
  default     = "GeneralPurpose"
}

variable "mysql_family" {
  description = "The family of hardware Gen4 or Gen5"
  default     = "Gen5"
}

variable "storage_size" {
  description = "Max storage allowed for a server 5120 MB to 1048576 MB(1TB) for Basic SKU and 5120 MB to 4194304 MB(4TB) for General Purpose/Memory Optimized SKUs"
}

variable "backup_retention_days" {
  description = "Backup retention days for the server, supported values are between 7 and 35 days"
  default     = "7"
}

variable "geo_redundant_backup" {
  description = "Enable Geo-redundant or not for server backup(Enabled or Disabled)"
  default     = "Disabled"
}

variable "server_username" {
  description = "The Administrator Login Username for the MySQL Server"
}

variable "server_password" {
  description = "The Administrator Login Password for the MySQL Server"
}

variable "mysql_version" {
  description = "The specify the version of MySQL. Valid values are 5.6 and 5.7"
  default     = "5.6"
}

variable "ssl_enforcement" {
  description = "Specifies if SSL should be enforced on connections. Possible values are Enabled and Disabled"
}

/*variable "firewall_rule_name" {
  description = "The name of the MySQL Firewall Rule"
  type        = "list"
}

variable "start_ip" {
  description = "The Start IP Address associated with this Firewall Rule"
  type        = "list"
}

variable "end_ip" {
  description = "The End IP Address associated with this Firewall Rule"
  type        = "list"
}

variable "vnet_rule_name" {
  description = "The name of the MySQL Virtual Network Rule"
}*/

variable "subnet_name" {
  description = "The name of the subnet "
}

variable "vnet_name" {
  description = "The name of the virtual network "
}
variable "out_resgrp_name" {
  default = "dummy"
}
variable "out_subnet_id" {
  default = "dummy"
}
variable "tags" {
  type        = "map"
  default     = {}
}