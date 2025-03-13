terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.111.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
  }
  required_version = ">= 0.13"
}


provider "azurerm" {
  skip_provider_registration = true
  features {}
}

module global {
  source = "../0_base/cfg"
}

module network {
  source = "../1_network/cfg"
}

module storage {
  source = "./cfg"
}

data "azurerm_resource_group" "core_rg" {
    name     = module.global.core_rg_name
}

data "azurerm_subnet" "infra_subnet" {
  name                 = module.network.infra_subnet_name
  virtual_network_name = module.network.vnet_name
  resource_group_name  = module.network.vnet_rg
}

data "azurerm_subnet" "compute_subnet" {
  name                 = module.network.compute_subnet_name
  virtual_network_name = module.network.vnet_name
  resource_group_name  = module.network.vnet_rg
  
}
data "azurerm_subnet" "amlfs_subnet" {
  count = module.storage.amlfs.create ? 1 : 0
  name                 = module.network.amlfs_subnet_name
  virtual_network_name = module.network.vnet_name
  resource_group_name  = module.network.vnet_rg
}

resource azurerm_storage_account "storage" {
  name                     = module.storage.storage_acct_name
  resource_group_name      = data.azurerm_resource_group.core_rg.name
  location                 = data.azurerm_resource_group.core_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "anf" {
  count = module.storage.create_anf && module.network.anf_subnet_name != null ? 1 : 0
  source = "../modules/storage/anf"
  name_prefix = module.storage.anf_prefix
  resource_group_name = module.global.core_rg_name
  ntap_pool_service_level = module.storage.ntap_pool_service_level
  ntap_pool_size_in_tb = module.storage.ntap_pool_size_in_tb
  ntap_volume_name = module.storage.ntap_volume_name
  ntap_volume_path = module.storage.ntap_volume_path
  ntap_volume_size_in_gb = module.storage.ntap_volume_size_in_gb
  
  vnet = {
    name = module.network.vnet_name
    rg = module.network.vnet_rg
    subnet = module.network.anf_subnet_name
  }
  }

  module "amlfs" {
    count = module.storage.amlfs.create ? 1 : 0
    source = "../modules/storage/amlfs"
    name_prefix = module.storage.amlfs.name_prefix
    rg = module.global.core_rg_name
    location = data.azurerm_resource_group.core_rg.location
    sku = module.storage.amlfs.sku
    storageCapacity = module.storage.amlfs.storageCapacity
    zone = module.storage.amlfs.zone

    vnet = {
      name = module.network.vnet_name
      rg  = module.network.vnet_rg
      subnet = module.network.amlfs_subnet_name
    }

    maintenance = {
      dayOfWeek = module.storage.amlfs.maintenance_day
      timeOfDay = module.storage.amlfs.maintenance_time
    }

    enable_hsm = module.storage.amlfs.enable_hsm

    hsm_sa = {
      storage_acct_name = module.storage.amlfs.hsm_sa
      rg   = module.storage.amlfs.hsm_sa_rg
      create_containers = module.storage.amlfs.create_containers
      data_container_name = module.storage.amlfs.data_container_name
      logging_container_name = module.storage.amlfs.logging_container_name
      import_path = module.storage.amlfs.import_path
    }

    depends_on = [ azurerm_storage_account.storage ]
  
  }

resource "azurerm_storage_account_network_rules" "acls" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action             = "Deny"
  virtual_network_subnet_ids = module.storage.use_locker_for_hsm ? [data.azurerm_subnet.infra_subnet.id, 
                                                                    data.azurerm_subnet.compute_subnet.id, 
                                                                    data.azurerm_subnet.amlfs_subnet[0].id, ] : [data.azurerm_subnet.infra_subnet.id, 
                                                                                                              data.azurerm_subnet.compute_subnet.id]
  depends_on = [ azurerm_storage_account.storage, module.amlfs ]
}

