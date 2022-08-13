variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "virtual_network_subnet_id" {
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
variable "https_only" {
  type        = bool
  default     = false
  description = "Redirect all traffic made to the web app using HTTP to HTTPS."
}

variable "http2_enabled" {
  type        = bool
  default     = true
  description = "Whether clients are allowed to connect over HTTP 2.0."
}

variable "min_tls_version" {
  type        = string
  default     = "1.2"
  description = "The minimum supported TLS version."
}

variable "ftps_state" {
  type        = string
  default     = "Disabled"
  description = "Set the FTPS state value the web app. The options are: `AllAllowed`, `Disabled` and `FtpsOnly`."
}
variable "identity" {
  type        = any
  default     = {}
  description = "Managed service identity properties. This should be `identity` object."
}
variable "site_config" {
  type    = any
  default = {}

}
variable "storage_mounts" {
  type        = any
  default     = []
  description = "List of storage mounts."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the web app."
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
      name                      = "Default-Linux-hrmonDapr"
      app_service_plan_id       = var.app_service_plan_id
      virtual_network_subnet_id = var.virtual_network_subnet_id
      site_config               = var.site_config
    }, pl)

  ]


  identity = merge({
    enabled = true
    ids     = null
  }, var.identity)

  storage_mounts = [
    for s in var.storage_mounts : merge({
      name           = ""
      account_name   = ""
      access_key     = ""
      share_name     = ""
      container_name = ""
      mount_path     = ""
    }, s)
  ]
}
