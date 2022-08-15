# variable "role" {
#   type    = list(string)
#   default = []
# }
variable "scope" {
  type = string
}
variable "role_definition_name" {
  type = string
}
variable "principal_id" {
  type = list(string)
  default = []
}
# locals {
#   role = [var.principal_id]
  #   scope                = var.scope
  #   role_definition_name = var.role_definition_name

# }