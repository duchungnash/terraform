output "ids" {
  value = tomap({
    for nameplan in azurerm_service_plan.hrm_app_plan : nameplan.name => nameplan.id
  })
}
