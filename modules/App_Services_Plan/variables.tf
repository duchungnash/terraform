variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "configs" {
  type    = any
  default = []
}
variable "os_type" {
  type    = string
  default = "Linux"
}
locals {
  configs = [
    for config in var.configs : merge({
      os_type  = "Linux"
      sku_name = "P1v2"
      name     = "Default-App-Service-Plan"
    }, config)
  ]
}


