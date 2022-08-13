variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
# variable "sku_name" {
#   type    = string
#   default = ""
# }
variable "tags" {
  type        = map(string)
  default     = {}
  description = " Map of tags to assign to the resources."
}
variable "plan" {
  type    = any
  default = []
}
variable "os_type" {
  type    = string
  default = "Linux"
}
locals {
  plan = [
    for pl in var.plan : merge({
      os_type  = "Linux"
      sku_name = "P1v2"
      name     = "Default-plan-name"
    }, pl)
  ]
}


