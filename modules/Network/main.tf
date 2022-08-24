#Azure Generic vNet Module
locals {
  public_azurerm_subnets = {
    for index, subnet in azurerm_subnet.public_subnet :
    subnet.name => subnet.id
  }

  private_azurerm_subnets = {
    for index, subnet in azurerm_subnet.private_subnet :
    subnet.name => subnet.id
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "public_subnet" {
  count                = length(var.public_subnet_names)
  name                 = var.public_subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_prefixes[count.index]]
  service_endpoints    = lookup(var.subnet_service_endpoints, var.public_subnet_names[count.index], null)

  dynamic "delegation" {
    for_each = var.enable_delegation ? { key = "enable delegation" } : {}
    content {
      name = "${var.public_subnet_names[count.index]}-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

  dynamic "delegation" {
    for_each = var.enable_delegation ? { key = "enable delegation" } : {}
    content {
      name = "${var.private_subnet_names[count.index]}-delegation"
      service_delegation {
        name    = "Microsoft.Web/hostingEnvironments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

}

resource "azurerm_subnet" "private_subnet" {
  count                = length(var.private_subnet_names)
  name                 = var.private_subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_prefixes[count.index]]
  service_endpoints    = lookup(var.subnet_service_endpoints, var.private_subnet_names[count.index], null)

  dynamic "delegation" {
    for_each = var.enable_delegation && !var.is_ase && (length(regexall("vms", var.private_subnet_names[count.index])) == 0) ? { key = "enable delegation" } : {}
    content {
      name = "${var.private_subnet_names[count.index]}-serverFarms-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

  dynamic "delegation" {
    for_each = var.enable_delegation && var.is_ase && (length(regexall("vms", var.private_subnet_names[count.index])) == 0) ? { key = "enable delegation" } : {}
    content {
      name = "${var.private_subnet_names[count.index]}-hostingEnvironments-delegation"
      service_delegation {
        name    = "Microsoft.Web/hostingEnvironments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  for_each                  = var.nsg_public_ids
  subnet_id                 = local.public_azurerm_subnets[each.key]
  network_security_group_id = each.value
}

resource "azurerm_subnet_network_security_group_association" "private" {
  for_each                  = var.nsg_private_ids
  subnet_id                 = local.private_azurerm_subnets[each.key]
  network_security_group_id = each.value
}
