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
  source = "./cfg"
}

data "azurerm_resource_group" "core_rg" {
    name     = module.global.core_rg_name
}

resource azurerm_virtual_network "vnet" {
  count = module.network.create_vnet ? 1 : 0
  name                = module.network.vnet_name
  location            = data.azurerm_resource_group.core_rg.location
  resource_group_name = data.azurerm_resource_group.core_rg.name
  address_space       = [ module.network.vnet_cidr ]
}

resource "azurerm_subnet" "vnet_subnet" {
  for_each = { for subnet in module.network.subnets : subnet.name => subnet 
  if module.network.create_vnet == true 
  }

  name                 = each.value.name
  address_prefixes      = [each.value.cidr]
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  resource_group_name  = azurerm_virtual_network.vnet[0].resource_group_name
  service_endpoints = (each.value.key == "infra" || each.value.key == "compute") ? ["Microsoft.Storage"] : []

  dynamic "delegation" {
    for_each = each.value.key == "anf" ? [1] : []
    content {
      name = "delegation"
      service_delegation {
        name    = "Microsoft.Netapp/volumes"
        actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
}

module vpn {
  source = "../modules/network/vpn"
  count = module.network.create_vpn ? 1 : 0
  name_prefix = module.network.vpn_prefix
  resource_group_name = module.global.core_rg_name
  vnet = {
    name = module.network.vnet_name
    rg = module.network.vnet_rg
  }
  depends_on = [ azurerm_subnet.vnet_subnet, azurerm_virtual_network.vnet ]
}






