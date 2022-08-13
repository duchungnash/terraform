# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">=3.15.0"
#     }

#   }
#   # backend "azurerm" {
#   #   resource_group_name  = "test257"
#   #   storage_account_name = "duchungstorage"
#   #   container_name       = "duchungacr2"
#   #   key                  = "terraform.tfstate"
#   # }

#   #   required_version = ""
# }
terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 1.32"
  }
}
provider "azurerm" {
  subscription_id = "77f03b7d-819d-431e-98c2-28866179eb22"
  features {}
}