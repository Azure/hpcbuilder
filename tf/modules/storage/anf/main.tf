# Resource Group

# target RG
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# target vnet
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  resource_group_name = var.vnet.rg
}

# target subnet
data "azurerm_subnet" "anf_subnet" {
  name                 = var.vnet.subnet 
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}


data azurerm_client_config "current" {}

resource "azurerm_netapp_account" "ntap_account" {
  name                = "${var.name_prefix}-acct"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_netapp_pool" "ntap_pool" {
  name                = "${var.name_prefix}-pool"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.ntap_account.name
  service_level       = var.ntap_pool_service_level
  size_in_tb          = var.ntap_pool_size_in_tb
}

resource "azurerm_netapp_volume" "ntap_volume" {
  name                = var.ntap_volume_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.ntap_account.name
  pool_name           = azurerm_netapp_pool.ntap_pool.name
  volume_path         = var.ntap_volume_path
  service_level       = var.ntap_pool_service_level
  storage_quota_in_gb = var.ntap_volume_size_in_gb
  subnet_id           = data.azurerm_subnet.anf_subnet.id
  network_features = "Standard"
  protocols = [ "NFSv3" ]
  security_style = "unix"

  export_policy_rule {
    rule_index = 1
    unix_read_write = true
    protocols_enabled = [ "NFSv3" ]
    allowed_clients = ["0.0.0.0/0"]
    root_access_enabled = true
  }
}