variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "name" {
  type        = string
  default     = ""
  description = "(Required) The name of the resource group. Must be unique on your Azure subscription"
}

variable "project" {
  type        = string
  default     = ""
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
variable "env" {
  type    = string
  default = "main"
}
variable "administrator_password" {
  type    = string
  default = "sdkjvnjkwj!#T!#^@#^"
}
variable "administrator_login" {
  type    = string
  default = "duchung"
}