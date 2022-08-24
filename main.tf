resource "azurerm_resource_group" "resource_group" {
  name     = "${var.rg_name}-env-${var.env}"
  location = var.rg_location
  tags = {
    project = var.project
    owner   = var.owner
  }
}
module "App_Services_Plan" {
  depends_on = [
    azurerm_resource_group.resource_group
  ]
  source      = "./modules/App_Services_Plan"
  rg_name     = azurerm_resource_group.resource_group.name
  rg_location = var.rg_location
  configs = [
    {
      sku_name = "B1"
      name     = "HrmonDapr-App-Plan"
      os_type  = "Linux"
    }
  ]
}
module "Linux_App_Services" {
  depends_on = [
    module.App_Services_Plan
  ]
  source      = "./modules/Linux_Web_App"
  rg_name     = azurerm_resource_group.resource_group.name
  rg_location = var.rg_location
  plan_linux_app = [
    {
      name                = "ApiGateWayHrmonDaprCode-${var.env}"
      app_service_plan_id = module.App_Services_Plan.ids.HrmonDapr-App-Plan
      site_config = {
        application_stack = {
          dotnet_version = "6.0"
        }
      }
    },
    {
      name                = "AdminHrmDapr-${var.env}"
      app_service_plan_id = module.App_Services_Plan.ids.HrmonDapr-App-Plan
      site_config = {
        application_stack = {
          docker_image     = "hrmondapr.azurecr.io/admin-api"
          docker_image_tag = "227"
        }
      }
    },
    {
      name                = "EmployeeHrmonDapr-${var.env}"
      app_service_plan_id = module.App_Services_Plan.ids.HrmonDapr-App-Plan
      site_config = {
        application_stack = {
          docker_image     = "hrmondapr.azurecr.io/employee"
          docker_image_tag = "227"
        }
      }
    },
    {
      name                = "CommunicationHrmDapr-${var.env}"
      app_service_plan_id = module.App_Services_Plan.ids.HrmonDapr-App-Plan
      site_config = {
        application_stack = {
          docker_image     = "hrmondapr.azurecr.io/communication"
          docker_image_tag = "227"
        }
      }
    },
  ]
  tags = {
    project = var.project
    owner   = var.owner
  }
}
module "bus_service" {
  depends_on = [
    azurerm_resource_group.resource_group
  ]
  source = "./modules/Bus_Services"
  name   = "bushrmondapr-${var.env}"

  rg_name     = azurerm_resource_group.resource_group.name
  rg_location = var.rg_location
  sku         = "Standard"
  topics = [
    {
      max_size            = "1024"
      name                = "topic"
      enable_partitioning = true
      authorization_rules = [
        {
          name   = "topic_rules"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
  queues = [
    {
      max_size = "1024"
      name     = "queues"
    }
  ]
}
resource "azurerm_network_security_group" "example" {
  name                = "nsg-hrmonDapr-env-${var.env}"
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.resource_group.name
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "80,443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
module "vnet" {
  depends_on = [
    azurerm_resource_group.resource_group
  ]
  source                  = "./modules/Network"
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = var.rg_location
  name                    = "vnet1-${var.env}"
  address_space           = ["10.8.0.0/16"]
  private_subnet_prefixes = ["10.8.3.0/24"]
  private_subnet_names    = ["prsub"]
  public_subnet_names     = ["subneta", ]
  public_subnet_prefixes  = ["10.8.1.0/24", ]
  nsg_public_ids          = {
    subneta               = azurerm_network_security_group.example.id
  }
}
module "postgree" {
  depends_on = [
    azurerm_resource_group.resource_group
  ]
  source                        = "./modules/Postgree_Server"
  rg_name                       = azurerm_resource_group.resource_group.name
  rg_location                   = var.rg_location
  server_name                   = "hrm-database-server-${var.env}"
  sku_name                      = "GP_Gen5_2"
  storage_mb                    = 5120
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  server_version                = "11"
  ssl_enforcement_enabled       = true
  public_network_access_enabled = true
  db_names                      = ["hrmdatabase1-${var.env}", "hrmdatabase2-${var.env}"]
  db_charset                    = "UTF8"
  db_collation                  = "English_United States.1252"
}
module "azurerm_role_assignment" {
  depends_on = [
    module.postgree, module.Linux_App_Services
  ]
  source               = "./modules/role_assignment"
  scope                = module.postgree.server_id
  role_definition_name = "Owner"
  principal_id = [
    module.Linux_App_Services.printical_id_3,
    module.Linux_App_Services.printical_id_0,
    module.Linux_App_Services.printical_id_1,
    module.Linux_App_Services.printical_id_2
  ]
}
