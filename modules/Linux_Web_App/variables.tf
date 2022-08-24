variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "plan_linux_app" {
  type    = any
  default = []
}
variable "app_service_plan_id" {
  type    = string
  default = ""
}
variable "identity" {
  type        = any
  default     = {}
}
variable "site_config" {
  type    = any
  default = {}
}
variable "tags" {
  type        = map(string)
  default     = {}
}
variable "dotnet_version" {
  type    = string
  default = "6.0"
}
variable "php_version" {
  type    = string
  default = "8.0"
}
locals {
  plan_linux_app = [
    for pl in var.plan_linux_app : merge({
      name                = "Default-Linux-hrmonDapr"
      app_service_plan_id = var.app_service_plan_id
      site_config         = var.site_config
    }, pl)
  ]
  identity = merge({
    enabled = true
    ids     = null
  }, var.identity)
}
