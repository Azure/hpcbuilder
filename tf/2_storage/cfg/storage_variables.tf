locals {
  global_config_file="${path.cwd}/../0_base/cfg/base_config.yml"
  config_file="${path.cwd}/../2_storage/cfg/storage_config.yml"
  config_yml=yamldecode(file(local.config_file))
  global_config_yml=yamldecode(file(local.global_config_file))


  storage_acct_name = local.config_yml["cyclecloud_locker"]["name"]
  storage_acct_rg = local.global_config_yml["core-rg"]["name"]

  create_anf = local.config_yml["anf_storage"]["create"] == 1 ? true : false
  create_amlfs = try(local.config_yml["amlfs_storage"]["create"] == 1 ? true : false, false)
  enable_hsm = local.create_amlfs && local.config_yml["amlfs_storage"]["hsm_storage"]["enable"] == 1 ? true : false

  anf_prefix = local.create_anf ? local.config_yml["anf_storage"]["name_prefix"] : null

  
  ntap_pool_service_level   = local.create_anf ? local.config_yml["anf_storage"]["ntap_pool_service_level"]: null
  ntap_pool_size_in_tb      = local.create_anf ? local.config_yml["anf_storage"]["ntap_pool_size_in_tb"]: null 

  ntap_volume_name          = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_name"]: null
  ntap_volume_path          = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_path"]: null
  ntap_volume_size_in_gb    = local.create_anf ? local.config_yml["anf_storage"]["ntap_volume_size_in_gb"]: null 

  amlfs = {
    create                 = local.create_amlfs
    name_prefix            = local.create_amlfs ? local.config_yml["amlfs_storage"]["name_prefix"] : null
    sku                    = local.create_amlfs ? local.config_yml["amlfs_storage"]["sku"] : null
    zone                   = local.create_amlfs ? local.config_yml["amlfs_storage"]["zone"] : null
    storageCapacity        = local.create_amlfs ? local.config_yml["amlfs_storage"]["size_in_tb"] : null
    maintenance_day        = local.create_amlfs ? local.config_yml["amlfs_storage"]["maintenance"]["day"] : null
    maintenance_time       = local.create_amlfs ? local.config_yml["amlfs_storage"]["maintenance"]["time"] : null
    enable_hsm             = local.enable_hsm
    hsm_sa                 = local.create_amlfs && local.enable_hsm ? local.config_yml["amlfs_storage"]["hsm_storage"]["hsm_storage_account"]["name"] : null
    hsm_sa_rg              = local.create_amlfs && local.enable_hsm ? try(local.config_yml["amlfs_storage"]["hsm_storage"]["hsm_storage_account"]["rg"], local.storage_acct_rg ) : null
    import_path            = local.create_amlfs && local.enable_hsm ? local.config_yml["amlfs_storage"]["hsm_storage"]["import_path"] : null
    create_containers      = local.create_amlfs && local.enable_hsm && local.config_yml["amlfs_storage"]["hsm_storage"]["hsm_storage_account"]["create_containers"] == 1 ? true : false
    data_container_name    = local.create_amlfs && local.enable_hsm ? local.config_yml["amlfs_storage"]["hsm_storage"]["data_container"] : null
    logging_container_name = local.create_amlfs && local.enable_hsm ? local.config_yml["amlfs_storage"]["hsm_storage"]["logging_container"]: null 
  }
  
}