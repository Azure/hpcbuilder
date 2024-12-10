locals {
  config_file="${path.cwd}/../0_base/cfg/base_config.yml"
  config_yml=yamldecode(file(local.config_file))

  location = local.config_yml["location"]

  core_rg_name=local.config_yml["core-rg"]["name"]

  flex_rg_name=local.config_yml["flex-rg"]["name"]

  kv_name=local.config_yml["keyvault"]["name"]

  admin_username=local.config_yml["admin"]["username"]
}