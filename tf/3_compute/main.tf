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
  source = "../2_storage/cfg"
}

module compute {
  source = "./cfg"
}

data "azurerm_resource_group" "core_rg" {
    name     = module.global.core_rg_name
}

data "azurerm_key_vault" "kv" {
  name                = module.global.kv_name
  resource_group_name = module.global.kv_rg
}

data "azurerm_key_vault_secret" "ssh_key" {
  name = "${module.global.admin_username}-ssh-public-key"
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "password" {
  name = "${module.global.admin_username}-pw"
  key_vault_id = data.azurerm_key_vault.kv.id
}

module "cyclecloud" {
  source = "../modules/compute/cyclecloud"
  name_prefix = module.compute.cycle_config.prefix
  resource_group_name = module.global.flex_rg_name
  vm_size = module.compute.cycle_config.vm_size
  cc_version = module.compute.cycle_config.version
  

  vnet = {
    name = module.network.vnet_name
    rg = module.network.vnet_rg
    subnet = module.network.infra_subnet_name
  }
  locker = {
    storage_acct_name = module.storage.storage_acct_name
    rg = module.global.core_rg_name
  }

  admin = {
    username = module.global.admin_username
    public_key = data.azurerm_key_vault_secret.ssh_key.value
    password = data.azurerm_key_vault_secret.password.value
  }

  use_image_id = module.compute.cycle_image.type == "custom" ? true : false
  image_id = module.compute.cycle_image.type == "custom" ? module.compute.cycle_config.image_id : null

  image = module.compute.cycle_image.type == "custom" ? null : {
    publisher = module.compute.cycle_image.publisher
    offer = module.compute.cycle_image.offer
    sku = module.compute.cycle_image.sku    
  }

  operating_system = module.compute.cycle_image.os_type

}