resource "azurerm_service_plan" "hrm_app_plan" {
  count               = length(local.plan)
  name                = local.plan[count.index].name
  location            = var.rg_location
  resource_group_name = var.rg_name
  os_type             = local.plan[count.index].os_type
  sku_name            = local.plan[count.index].sku_name
  tags                = var.tags
}