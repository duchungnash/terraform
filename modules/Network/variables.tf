variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_names" {
  type    = list(string)
  default = []
}

variable "public_subnet_prefixes" {
  type    = list(string)
  default = []
}

variable "subnet_service_endpoints" {
  description = "A map of subnet name to service endpoints to add to the subnet."
  type        = map(any)
  default     = {}
}

variable "private_subnet_names" {
  type    = list(string)
  default = []
}

variable "private_subnet_prefixes" {
  type    = list(string)
  default = []
}

variable "enable_delegation" {
  type        = bool
  description = "Subnet delegation enable"
  default     = false
}

variable "nsg_public_ids" {
  description = "A map of subnet name to Network Security Group IDs"
  type        = map(string)
  default = {
  }
}

variable "nsg_private_ids" {
  type    = map(string)
  default = {}
}

variable "is_ase" {
  type    = bool
  default = false
}
