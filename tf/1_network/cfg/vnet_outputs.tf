output "vnet_name" {
  description = "Name of the vnet"
  value       = local.vnet_name
}

output "vnet_cidr" {
  description = "address space of the vnet"
  value       = local.vnet_cidr
}

output "infra_subnet_name" {
  description = "Name of the infra subnet"
  value       = local.infra_subnet_name
}

output "compute_subnet_name" {
  description = "Name of the compute subnet"
  value       = local.compute_subnet_name
}

output "anf_subnet_name" {
  description = "Name of the anf subnet"
  value       = local.anf_subnet_name
}

output "amlfs_subnet_name" {
  description = "Name of the amlfs subnet"
  value       = local.amfls_subnet_name
}

output "create_vnet" {
  description = "boolean to create the vnet"
  value       = local.create_vnet
  
}

output "create_vpn" {
  description = "boolean to create the vpn"
  value       = local.create_vpn
}

output "vpn_prefix" {
  description = "Prefix for the vpn"
  value       = local.vpn_prefix
}

output "vnet_rg" {
  description = "Resource group for the vnet"
  value       = local.vnet_rg
}

output "subnets" {
  description = "Subnets in the vnet"
  value       = local.subnets
}

