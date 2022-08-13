output "id" {
  description = "The id of the newly created vNet"
  value       = var.create_new_vnet ? azurerm_virtual_network.vnet.id : ""
}

output "name" {
  description = "The Name of the newly created vNet"
  value       = var.create_new_vnet ? azurerm_virtual_network.vnet.name : ""
}

output "location" {
  description = "The location of the newly created vNet"
  value       = var.create_new_vnet ? azurerm_virtual_network.vnet.location : ""
}

output "address_space" {
  description = "The address space of the newly created vNet"
  value       = var.create_new_vnet ? azurerm_virtual_network.vnet.address_space : []
}

output "public_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  # value       = azurerm_subnet.public_subnet.*.id
  value = tomap({
    for subnet in azurerm_subnet.public_subnet : subnet.name => subnet.id
  })
}

output "private_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  # value       = azurerm_subnet.private_subnet.*.id
  value = tomap({
    for subnet in azurerm_subnet.private_subnet : subnet.name => subnet.id
  })
}
