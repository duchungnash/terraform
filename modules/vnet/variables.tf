variable "name" {
  type        = string
  description = "(Required) The name of the resource group. Must be unique on your Azure subscription"
}

variable "project" {
  type        = string
  description = "(Required) The name of the project"
}

variable "environment" {
  type        = string
  description = "(Optional) Environment name. If not specified, this module will use workspace as default value"
  default     = ""
}

variable "owner" {
  type        = string
  description = "(Optional) Adds a tag indicating the creator of this resource"
  default     = ""
}

variable "vnet_depends_on" {
  # the value doesn't matter; we're just using this variable
  # to propagate dependencies.
  type    = any
  default = []
}

variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "vnet_id" {
  type    = string
  default = ""
}

variable "create_new_vnet" {
  type        = bool
  description = "Create new vnet or not"
  default     = true
}

variable "vnet_name" {
  default = ""
  type    = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}

variable "public_subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(string)
  default     = []
}

variable "private_subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = []
}

variable "private_subnet_names" {
  description = "A list of private subnets inside the vNet."
  type        = list(string)
  default     = []
}

variable "nsg_private_ids" {
  type    = map(string)
  default = {}
}

variable "private_route_tables_ids" {
  type    = map(string)
  default = {}
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}

variable "public_route_tables_ids" {
  description = "A map of public subnet name to Route table ids"
  type        = map(string)
  default     = {}
}

variable "nsg_public_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)

  default = {
  }
}

variable "vnet_ids_central_us" {
  type    = list(string)
  default = []
}

variable "vnet_infomations_central_us" {
  description = "The infomations vnet (name vnet, id)"
  type = list(object({
    name = string
    id   = string
  }))
  default = [
    {
      name = "default-name"
      id   = "default-id"
    }
  ]
}

variable "vnet_infomations_global" {
  description = "The infomations vnet (name vnet, id)"
  type = list(object({
    localtion = string
    name      = string
    id        = string
  }))
  default = [
    {
      localtion = "type some location"
      name      = "type some name"
      id        = "type some id"
    }
  ]
}

variable "enable_peering_location" {
  type    = bool
  default = false
}

variable "enable_peering_global" {
  type    = bool
  default = false
}

variable "enable_delegation" {
  type        = bool
  description = "Subnet delegation enable"
  default     = false
}

variable "is_ase" {
  type    = bool
  default = false
}