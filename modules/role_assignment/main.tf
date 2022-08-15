resource "azurerm_role_assignment" "example" {
  count                = length(var.principal_id)
  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = var.principal_id[count.index]
}