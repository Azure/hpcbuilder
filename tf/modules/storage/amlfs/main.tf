data azuread_service_principal lustre_sp {
  display_name = "HPC Cache Resource Provider"
}

data azurerm_storage_account hsm {
  count = var.enable_hsm ? 1 : 0
  name                = var.hsm_sa.storage_acct_name
  resource_group_name = var.hsm_sa.rg
}

data azurerm_subnet amlfs_subnet {
  name                 = var.vnet.subnet
  virtual_network_name = var.vnet.name
  resource_group_name  = var.vnet.rg
}


resource azurerm_role_assignment storage_acct_contributor {
  count = var.enable_hsm ? 1 : 0
  role_definition_name = "Storage Account Contributor" 
  principal_id         = data.azuread_service_principal.lustre_sp.object_id
  scope                = data.azurerm_storage_account.hsm[0].id
}

resource azurerm_role_assignment blob_data_contributor {
  count = var.enable_hsm ? 1 : 0
  role_definition_name = "Storage Blob Data Contributor" 
  principal_id         = data.azuread_service_principal.lustre_sp.object_id
  scope                = data.azurerm_storage_account.hsm[0].id
}

data azurerm_storage_container existing_data {
  count = var.enable_hsm && !var.hsm_sa.create_containers ? 1 : 0
  name                  = var.hsm_sa.data_container_name
  storage_account_name  = data.azurerm_storage_account.hsm[0].name
}

data azurerm_storage_container existing_logging {
  count = var.enable_hsm && !var.hsm_sa.create_containers ? 1 : 0
  name                  = var.hsm_sa.logging_container_name
  storage_account_name  = data.azurerm_storage_account.hsm[0].name
}

resource azurerm_storage_container data {
  count = var.enable_hsm && var.hsm_sa.create_containers ? 1 : 0
  name                  = var.hsm_sa.data_container_name
  storage_account_name    = data.azurerm_storage_account.hsm[0].name
}

resource "azurerm_storage_container" "logging" {
  count = var.enable_hsm && var.hsm_sa.create_containers ? 1 : 0
  name                  = var.hsm_sa.logging_container_name
  storage_account_name    = data.azurerm_storage_account.hsm[0].name
}

resource azurerm_managed_lustre_file_system amlfs {
  name                   = var.name_prefix
  resource_group_name    = var.rg
  location               = var.location
  sku_name               = var.sku
  storage_capacity_in_tb = var.storageCapacity
  subnet_id              = data.azurerm_subnet.amlfs_subnet.id
  zones                  = var.zone 
  
  maintenance_window {
    day_of_week        = var.maintenance.dayOfWeek
    time_of_day_in_utc = var.maintenance.timeOfDay
  }

  dynamic hsm_setting {
    for_each = var.enable_hsm ? [1] : []
    content {
      container_id         = var.hsm_sa.create_containers ? azurerm_storage_container.data[0].resource_manager_id : data.azurerm_storage_container.existing_data[0].id
      logging_container_id = var.hsm_sa.create_containers ? azurerm_storage_container.logging[0].resource_manager_id : data.azurerm_storage_container.existing_logging[0].id
      import_prefix        = var.hsm_sa.import_path
    }
  }
  depends_on = [
    azurerm_role_assignment.storage_acct_contributor,
    azurerm_role_assignment.blob_data_contributor, 

  ]
}