output "printical_id_0" {
  #       value = tomap({
  #     for nameplan in azurerm_linux_web_app.main : nameplan.name => nameplan.identity.principal_id
  #   })
  value = azurerm_app_service.main[0].identity[0].principal_id
}