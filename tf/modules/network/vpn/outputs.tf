
output "vpn_name" {
  description = "name of VPN resource created"
  value       = azurerm_virtual_network_gateway.vpn.name
  
}