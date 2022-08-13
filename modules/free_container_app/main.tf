resource "azurerm_app_service" "main" {
  count               = length(local.plan_container)
  name                = local.plan_container[count.index].name
  location            = var.rg_location
  resource_group_name = var.rg_name
  app_service_plan_id = local.plan_container[count.index].app_service_plan_id

  client_affinity_enabled = false

  https_only = var.https_only

  site_config {
    # always_on        = local.always_on
    app_command_line = var.command
    ftps_state       = var.ftps_state
    ip_restriction   = local.ip_restrictions
    linux_fx_version = "${local.container_type}|${local.container_type == "DOCKER" ? local.plan_container[count.index].container_image : local.container_config}"
  }

  app_settings = merge(var.app_settings, local.app_settings)

  identity {
    type = (local.identity.enabled ?
      (local.identity.ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned") :
      "None"
    )
    identity_ids = local.identity.ids
  }

  dynamic "storage_account" {
    for_each = local.storage_mounts
    iterator = s

    content {
      name         = s.value.name
      type         = s.value.share_name != "" ? "AzureFiles" : "AzureBlob"
      account_name = s.value.account_name
      share_name   = s.value.share_name != "" ? s.value.share_name : s.value.container_name
      access_key   = s.value.access_key
      mount_path   = s.value.mount_path
    }
  }
  tags = var.tags

}

