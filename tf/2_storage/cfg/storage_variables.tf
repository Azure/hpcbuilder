locals {
  config_file="${path.cwd}/../2_storage/cfg/storage_config.yml"
  config_yml=yamldecode(file(local.config_file))

  storage_acct_name = local.config_yml["cyclecloud_locker"]["name"]
  
}