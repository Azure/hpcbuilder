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
data "azurerm_subnet" "subnet" {
  name = "GatewaySubnet"
  resource_group_name = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name  
}

data azurerm_client_config "current" {}


resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "${var.name_prefix}-vpn-pip"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Dynamic" 
}

resource "azurerm_virtual_network_gateway" "vpn" {
  name               = "${var.name_prefix}-vpn-gw"
  resource_group_name = data.azurerm_resource_group.rg.name
  location           = data.azurerm_resource_group.rg.location
  type               = "Vpn"
  vpn_type           = "RouteBased"
  
  active_active = false
  enable_bgp = false
  sku                = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.subnet.id
  }

  vpn_client_configuration {
    address_space = var.point2site_address_pool
    aad_tenant = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/" 
    aad_audience = var.aad_audience
    aad_issuer = "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/" 
    vpn_client_protocols = ["OpenVPN"]
  }
}