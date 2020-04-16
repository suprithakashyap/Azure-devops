# Resource group variables

resource_grp_name           = "__resource_grp_name__"
location                    = "__location__"

# Variables for security group

security_group_name = ["nsg1", "nsg2"]
tags                = {
  Environment         = "__Environment__"
  Application         = "__Application__"
  BusinessOwner       = "__BusinessOwner_"
}

# Network variables

vnet_name                   = "__vnet_name__"
address_space               = "__vnet_address__"

subnet_names = ["sub1", "sub2", "sub3"]
subnet_prefixes = ["14.0.1.0/24", "14.0.2.0/24", "14.0.3.0/24"]



# Storage Account variables

storage_account_name      = "__storage_account_name__"
account_tier              = "__account_tier__"
account_replication_type  = "__account_replication_type__"
account_kind              = "__account_kind__"
access_tier               = "__access_tier__"

