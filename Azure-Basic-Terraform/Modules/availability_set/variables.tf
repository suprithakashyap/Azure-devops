variable "availability_set_name" {
  description = "The name of the Availability Set"
  default     = ""
}

variable "location" {
  description = "Location in which the availability set has to be created"
  default     = ""
}

variable "resgrp_name" {
  description = "The name of the resource group"
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

variable "tags" {
  type        = "map"
  default     = {}
}

variable "out_resgrp_name" {
  default = "dummy"
}