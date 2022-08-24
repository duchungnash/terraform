variable "rg_name" {
  type    = string
  default = ""
}
variable "rg_location" {
  type    = string
  default = ""
}
variable "server_name" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "GP_Gen5_4"
}

variable "storage_mb" {
  type    = number
  default = 102400
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "geo_redundant_backup_enabled" {
  type    = bool
  default = false
}

variable "administrator_login" {
  type = string
}

variable "administrator_password" {
  type = string
}

variable "server_version" {
  type    = string
  default = "11"
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "db_names" {
  type    = list(string)
  default = []
}

variable "db_charset" {
  type    = string
  default = "UTF8"
}

variable "db_collation" {
  type    = string
  default = "English_United States.1252"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "postgresql_configurations" {
  description = "A map with PostgreSQL configurations to enable."
  type        = map(string)
  default     = {}
}

variable "ssl_enforcement_enabled" {
  description = "Specifies if SSL should be enforced on connections. Possible values are Enabled and Disabled."
  type        = bool
  default     = true
}