output "public_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value = tomap({
    for subnet in azurerm_subnet.public_subnet : subnet.name => subnet.id
  })
}

output "private_subnet_ids" {
  description = "The ids of subnets created inside the new vNet"
  value = tomap({
    for subnet in azurerm_subnet.private_subnet : subnet.name => subnet.id
  })
}
