variable "storage_account_name" {
  description = "The name for the storage account"
  default     = ""
}
variable "resgrp_name" {
  description = "The name of the resource group in which to create the storage account"
  default     = ""
}
variable "location" {
  description = "Location in which the storage account has to be created"
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
variable "tags" {
  type        = "map"
  default     = {}
}
variable "out_resgrp_name" {
  default = "dummy"
}