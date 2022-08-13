resource "azurerm_resource_group" "rg" {
  name     = "${var.rg_name}-env-${var.env}"
  location = var.rg_location
  tags = {
    project     = var.project
    environment = var.environment
    owner       = var.owner
  }
}
resource "azurerm_user_assigned_identity" "example" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.rg_location

  name = "search-api-ahihi"
}
module "vnet" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source                  = "../modules/vnet"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = var.rg_location
  name                    = "vnet1-${var.env}"
  project                 = var.project
  environment             = var.environment
  owner                   = var.owner
  address_space           = ["10.8.0.0/16"]
  private_subnet_prefixes = ["10.8.3.0/24"]
  private_subnet_names    = ["prsub"]
  public_subnet_names     = ["subneta", ]
  public_subnet_prefixes  = ["10.8.1.0/24", ]
  # enable_delegation       = true
}
# #name rg_group
module "app_plan" {
  depends_on = [
    azurerm_resource_group.rg, azurerm_user_assigned_identity.example
  ]
  source      = "../modules/hg_app_plan"
  rg_name     = azurerm_resource_group.rg.name
  rg_location = var.rg_location
  plan = [
    {
      sku_name = "B1"
      name     = "hrm-dapr-plan"
      os_type  = "Linux"
    },
    {

    }
    # {
    #Default-plan-name
    # }
  ]
}
module "web_app_container" {
  depends_on = [
    module.app_plan
  ]
  source              = "../modules/free_container_app"
  rg_name             = azurerm_resource_group.rg.name
  rg_location         = var.rg_location
  docker_registry_url = "duchungacr.azurecr.io"
  plan_container = [
    {
      name                = "hrmcontainer-dapr-employee-${var.env}"
      app_service_plan_id = module.app_plan.ids.hrm-dapr-plan
      container_image     = "duchungacr.azurecr.io/duchungacr:admin01"
      docker_registry_url = "duchungacr.azurecr.io"
    },
    {
      name                = "hrmcontainer-dapr-admin-${var.env}"
      app_service_plan_id = module.app_plan.ids.hrm-dapr-plan
      container_image     = "duchungacr.azurecr.io/duchungacr:alo1"
      docker_registry_url = "duchungacr.azurecr.io"
    },
    {
      name                = "hrmcontainer-dapr-communication-${var.env}"
      app_service_plan_id = module.app_plan.ids.hrm-dapr-plan
      container_image     = "duchungacr.azurecr.io/duchungacr:alo2"
      docker_registry_url = "duchungacr.azurecr.io"
    }
  ]
  tags = {
    name = "hung"
    oke  = "oal"
  }
  identity = {
    ids = [azurerm_user_assigned_identity.example.id]
  }
}
module "linux-web-app" {
  depends_on = [
    module.app_plan, module.vnet
  ]
  source      = "../modules/free_linux_app"
  rg_name     = azurerm_resource_group.rg.name
  rg_location = var.rg_location
  # virtual_network_subnet_id = module.vnet.public_subnet_ids.subneta
  plan_linux_app = [
    {
      name                = "dotnethrmapp-api-${var.env}"
      app_service_plan_id = module.app_plan.ids.hrm-dapr-plan
      site_config = {
        application_stack = {
          dotnet_version = "6.0"
        }
      }
    },
    {
      name                = "pythohrmapp-api-${var.env}"
      app_service_plan_id = module.app_plan.ids.hrm-dapr-plan
      site_config = {
        application_stack = {
          python_version = "3.8"
        }
      }
    }
  ]
  tags = {
    name = "hrmapp"
    oke  = "linux-api-app"
  }
  # identity = {
  #   ids = [azurerm_user_assigned_identity.example.id]
  # }
}
module "bus_service" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source = "../modules/free_bus"
  name   = "bushrmondapr-${var.env}"

  rg_name     = azurerm_resource_group.rg.name
  rg_location = var.rg_location
  sku         = "Standard"
  identity = {
    ids = [azurerm_user_assigned_identity.example.id]
  }
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
      # authorization_rules = [
      #   {
      #     name   = "queues_rules"
      #     rights = ["listen", "send"]
      #   }
      # ]
    }
  ]
}
module "postgree" {
  depends_on = [
    azurerm_resource_group.rg
  ]
  source      = "../modules/postgree"
  rg_name     = azurerm_resource_group.rg.name
  rg_location = var.rg_location

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

  # firewall_rule_prefix = "firewall-"
  # firewall_rules = [
  #   { name = "test1", start_ip = "10.0.0.5", end_ip = "10.0.0.8" },
  #   { start_ip = "127.0.0.0", end_ip = "127.0.1.0" },
  # ]

  # vnet_rule_name_prefix = "postgresql-vnet-rule-"
  # vnet_rules = [
  #   { name = "subnet1", subnet_id = "<subnet_id>" }
  # ]

  postgresql_configurations = {
    backslash_quote = "on",
  }
}
resource "azurerm_role_assignment" "example" {
  depends_on = [
    module.postgree, module.linux-web-app
  ]
  scope                = module.postgree.server_id
  role_definition_name = "Owner"
  # principal_id         = module.linux-web-app.printical_id.dotnethrmapp-api-${var.env}
  principal_id = module.linux-web-app.printical_id_0
}
# resource "azurerm_role_assignment" "example2" {
#   depends_on = [
#     module.postgree, module.linux-web-app
#   ]
#   scope                = module.postgree.server_id
#   role_definition_name = "Owner"
#   # principal_id         = module.linux-web-app.printical_id.dotnethrmapp-api-${var.env}
#   principal_id = module.linux-web-app.printical_id_1
# }