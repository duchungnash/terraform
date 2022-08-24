output "printical_id_0" {
   value = azurerm_linux_web_app.main[0].identity[0].principal_id
}
output "printical_id_1" {
   value = azurerm_linux_web_app.main[1].identity[0].principal_id
}
output "printical_id_2" {
   value = azurerm_linux_web_app.main[2].identity[0].principal_id
}
output "printical_id_3" {
   value = azurerm_linux_web_app.main[3].identity[0].principal_id
}


