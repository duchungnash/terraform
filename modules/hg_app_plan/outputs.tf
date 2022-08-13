output "ids" {
  # value = azurerm_service_plan.hrm_app_plan[0].id
  value = tomap({
    for nameplan in azurerm_service_plan.hrm_app_plan : nameplan.name => nameplan.id
  })
}
# output "id1" {
#   value = azurerm_service_plan.hrm_app_plan.id
# }