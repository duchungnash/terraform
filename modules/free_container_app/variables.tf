variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "plan_container" {
  type    = any
  default = []
}
variable "container_type" {
  type    = string
  default = "docker"
}

variable "container_config" {
  type    = string
  default = ""
}

variable "container_image" {
  type    = string
  default = ""
}



variable "enable_storage" {
  type    = string
  default = "false"
}

variable "start_time_limit" {
  type    = number
  default = 230
}

variable "command" {
  type    = string
  default = ""
}

variable "app_settings" {
  type    = map(string)
  default = {}
}


variable "always_on" {
  type    = bool
  default = true
}

variable "https_only" {
  type    = bool
  default = true
}

variable "ftps_state" {
  type    = string
  default = "Disabled"
}

variable "ip_restrictions" {
  type    = list(string)
  default = []
}


variable "docker_registry_username" {
  type    = string
  default = null
}

variable "docker_registry_url" {
  type    = string
  default = "https://index.docker.io"
}

variable "docker_registry_password" {
  type    = string
  default = null
}

variable "plan" {
  type    = map(string)
  default = {}
}

variable "identity" {
  type    = any
  default = {}
}

variable "storage_mounts" {
  type    = any
  default = []
}


variable "tags" {
  type    = map(string)
  default = {}
}
variable "app_service_plan_id" {
  type    = string
  default = ""
}
locals {
  plan_container = [
    for pl in var.plan_container : merge({
      name                = "Default-Linux-container-web"
      app_service_plan_id = var.app_service_plan_id
      docker_registry_url = var.docker_registry_url
      container_image     = var.container_image
    }, pl)
  ]
  app_settings = {
    "WEBSITES_CONTAINER_START_TIME_LIMIT" = var.start_time_limit
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = var.enable_storage
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.docker_registry_username
    "DOCKER_REGISTRY_SERVER_URL"          = var.docker_registry_url
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.docker_registry_password
  }

  container_type   = upper(var.container_type)
  container_config = base64encode(var.container_config)


  ip_restrictions = [
    for prefix in var.ip_restrictions : {
      ip_address  = split("/", prefix)[0]
      subnet_mask = cidrnetmask(prefix)
    }
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