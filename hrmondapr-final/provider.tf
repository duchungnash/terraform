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
  subscription_id = "5297aabb-563d-4a6c-a5a4-bf0d89450b72"
  features {}
}