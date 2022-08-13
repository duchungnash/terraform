

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

  vnet_name = "${var.name}-${var.project}-${var.environment}"
}

module "vnet_label" {
  source = "../tags"

  name        = local.vnet_name
  project     = var.project
  environment = var.environment
  owner       = var.owner

  tags = {
    Description = "managed by Terraform",
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = var.address_space
  dns_servers         = var.dns_servers

  tags = merge(
    var.tags,
    module.vnet_label.tags
  )

  depends_on = [var.vnet_depends_on]
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

resource "azurerm_subnet_route_table_association" "public_subnet" {
  for_each       = var.public_route_tables_ids
  route_table_id = each.value
  subnet_id      = local.public_azurerm_subnets[each.key]
}

resource "azurerm_subnet_route_table_association" "private_subnet" {
  for_each       = var.private_route_tables_ids
  route_table_id = each.value
  subnet_id      = local.private_azurerm_subnets[each.key]
}

# Vnet Peering

# Vnet peering to another locations (Vnet peering Global)
resource "azurerm_virtual_network_peering" "central_us_global" {
  count                        = (var.enable_peering_global ? 1 : 0) * length(var.vnet_infomations_global)
  name                         = "${azurerm_virtual_network.vnet.name}-to-${element(var.vnet_infomations_global.*.name, count.index)}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = element(var.vnet_infomations_global.*.id, count.index)
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = false
  depends_on            = [var.vnet_depends_on]
}

resource "azurerm_virtual_network_peering" "global" {
  count                        = (var.enable_peering_global ? 1 : 0) * length(var.vnet_infomations_global)
  name                         = "${element(var.vnet_infomations_global.*.name, count.index)}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = element(var.vnet_infomations_global.*.name, count.index)
  remote_virtual_network_id    = var.create_new_vnet ? azurerm_virtual_network.vnet.id : var.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  # `allow_gateway_transit` must be set to false for vnet Global Peering
  allow_gateway_transit = false
}

# vnet peering in same location Central US
resource "azurerm_virtual_network_peering" "central_us" {
  count                     = (var.enable_peering_location ? 1 : 0) * length(var.vnet_ids_central_us)
  name                      = "${azurerm_virtual_network.vnet.name}-to-${element(var.vnet_infomations_central_us.*.name, count.index)}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = element(var.vnet_infomations_central_us.*.id, count.index)
  depends_on                = [var.vnet_depends_on]
}

resource "azurerm_virtual_network_peering" "same_localtion" {
  count                     = (var.enable_peering_location ? 1 : 0) * length(var.vnet_ids_central_us)
  name                      = "${element(var.vnet_infomations_central_us.*.name, count.index)}-to-${azurerm_virtual_network.vnet.name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = element(var.vnet_infomations_central_us.*.name, count.index)
  remote_virtual_network_id = var.create_new_vnet ? azurerm_virtual_network.vnet.id : var.vnet_id
  depends_on                = [var.vnet_depends_on]
}
