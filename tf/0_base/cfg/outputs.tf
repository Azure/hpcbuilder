output "location" {
  description = "location of resource groups"
  value       = local.location
}

output "core_rg_name" {
  description = "name of core resource group"
  value       = local.core_rg_name
}

output "flex_rg_name" {
  description = "Name of the flex resource group"
  value       = local.flex_rg_name
}

output "kv_name" {
  description = "Name of the key vault"
  value       = local.kv_name
}

output "admin_username" {
  description = "admin username"
  value       = local.admin_username
}

