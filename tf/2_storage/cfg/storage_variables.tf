locals {
  config_file="${path.cwd}/../2_storage/cfg/storage_config.yml"
  config_yml=yamldecode(file(local.config_file))

  storage_acct_name = local.config_yml["cyclecloud_locker"]["name"]

  create_anf = local.config_yml["anf_storage"]["create"] == 1 ? true : false
  
  anf_prefix = local.create_anf ? local.config_yml["anf_storage"]["name_prefix"] : null

  
  ntap_pool_service_level   = local.create_anf ? local.config_yml["anf_storage"]["ntap_pool_service_level"]: null
  ntap_pool_size_in_tb      = local.create_anf ? local.config_yml["anf_storage"]["ntap_pool_size_in_tb"]: null 

  ntap_volume_name          = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_name"]: null
  ntap_volume_path          = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_path"]: null
  ntap_volume_size_in_gb    = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_size_in_gb"]: null 
  
}