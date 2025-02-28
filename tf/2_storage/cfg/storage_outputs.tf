output "storage_acct_name" {
  description = "storage account name"
  value = local.storage_acct_name
}
output "anf_prefix" {
  description = "anf prefix"
  value = local.anf_prefix
}
output "ntap_pool_service_level" {
  description = "ntap pool service level"
  value = local.ntap_pool_service_level
}
output "ntap_pool_size_in_tb" {
  description = "ntap pool size in tb"
  value = local.ntap_pool_size_in_tb
}
output "ntap_volume_name" {
  description = "ntap volume name"
  value = local.ntap_volume_name
}
output "ntap_volume_path" {
  description = "ntap volume path"
  value = local.ntap_volume_path
}
output "ntap_volume_size_in_gb" {
  description = "ntap volume size in gb"
  value = local.ntap_volume_size_in_gb
}
output "create_anf" {
  description = "create anf"
  value = local.create_anf
}