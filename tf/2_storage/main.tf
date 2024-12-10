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

resource azurerm_storage_account "storage" {
  name                     = module.storage.storage_acct_name
  resource_group_name      = data.azurerm_resource_group.core_rg.name
  location                 = data.azurerm_resource_group.core_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_network_rules" "acls" {
  storage_account_id = azurerm_storage_account.storage.id

  default_action             = "Deny"
  virtual_network_subnet_ids = [data.azurerm_subnet.infra_subnet.id, data.azurerm_subnet.compute_subnet.id]
  depends_on = [ azurerm_storage_account.storage ]
}



