resource "azurerm_service_plan" "hrm_app_plan" {
  count               = length(local.configs)
  name                = local.configs[count.index].name
  location            = var.rg_location
  resource_group_name = var.rg_name
  os_type             = local.configs[count.index].os_type
  sku_name            = local.configs[count.index].sku_name
  tags                = var.tags
}