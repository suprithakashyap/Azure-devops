# Resource group variables

resource_grp_name           = "__resource_grp_name__"
location                    = "__location__"

# Variables for security group

security_group_name = ["nsg1", "nsg2"]
tags                = {
  Environment         = "__Environment__"
  Application         = "__Application__"
  BusinessOwner       = "__BusinessOwner__"
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

# Compute variables

vm_name              =  ["imvm1", "imvm2"]
vm_size              =  ["Standard_B1ms", "Standard_B1ms"]
vm_subnet_name       =  "sub1"
username             =  "admintest"
password             =  "Mindtree@1"
nb_instances         =  "__instance_count__"

# Availability Set variables

availability_set_name      = "AS1"
fault_domain_count         = 3
update_domain_count        = 5
managed                    = "true"

# Load Balancer variables

lb_public_ip_name = "test"
load_balancer_name = "test-elb"


