resource "azurerm_linux_web_app" "main" {
  count               = length(local.plan_linux_app)
  name                = local.plan_linux_app[count.index].name
  location            = var.rg_location
  resource_group_name = var.rg_name
  service_plan_id     = local.plan_linux_app[count.index].app_service_plan_id
  site_config {
    dynamic "application_stack" {
      for_each = lookup(local.plan_linux_app[count.index].site_config, "application_stack", {}) != {} ? [1] : []
      content {
        java_version        = lookup(local.plan_linux_app[count.index].site_config.application_stack, "java_version", null)
        java_server         = lookup(local.plan_linux_app[count.index].site_config.application_stack, "java_server", null)
        java_server_version = lookup(local.plan_linux_app[count.index].site_config.application_stack, "java_server_version", null)
        php_version         = lookup(local.plan_linux_app[count.index].site_config.application_stack, "php_version", null)
        ruby_version        = lookup(local.plan_linux_app[count.index].site_config.application_stack, "ruby_version", null)
        dotnet_version      = lookup(local.plan_linux_app[count.index].site_config.application_stack, "dotnet_version", null)
        node_version        = lookup(local.plan_linux_app[count.index].site_config.application_stack, "node_version", null)
        python_version      = lookup(local.plan_linux_app[count.index].site_config.application_stack, "python_version", null)
        docker_image        = lookup(local.plan_linux_app[count.index].site_config.application_stack, "docker_image", null)
        docker_image_tag    = lookup(local.plan_linux_app[count.index].site_config.application_stack, "docker_image_tag", null)
      }
    }
  }
  identity {
    type = (local.identity.enabled ?
      (local.identity.ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned") :
      "None"
    )
    identity_ids = local.identity.ids
  }
  tags = var.tags
}
