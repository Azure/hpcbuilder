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

data "azurerm_client_config" "current" {}

module global {
  source = "./cfg"
}

resource "azurerm_resource_group" "core_rg" {
    name     = module.global.core_rg_name
    location = module.global.location
}

resource "azurerm_resource_group" "flex_rg" {
    name     = module.global.flex_rg_name
    location = module.global.location
}

resource "azurerm_key_vault" "kv" {
  name                = module.global.kv_name
  location            = resource.azurerm_resource_group.core_rg.location
  resource_group_name = resource.azurerm_resource_group.core_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Backup",
      "Restore",
      "Delete",
      "Recover",
      "Purge"
    ]

  }
}

module "keys" {
  source = "../modules/auth/ssh-key"
  name_prefix = module.global.admin_username
  keyvault_name = resource.azurerm_key_vault.kv.name
  keyvault_resource_group_name = resource.azurerm_resource_group.core_rg.name
  depends_on = [ resource.azurerm_key_vault.kv ]
  
}

module "password" {
  source = "../modules/auth/password"
  name_prefix = module.global.admin_username
  keyvault_name = resource.azurerm_key_vault.kv.name
  keyvault_resource_group_name = resource.azurerm_resource_group.core_rg.name
  depends_on = [ resource.azurerm_key_vault.kv ]
  
}

