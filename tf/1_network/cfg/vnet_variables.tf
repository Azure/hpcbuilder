locals {
  global_config_file="${path.cwd}/../0_base/cfg/base_config.yml"
  config_file="${path.cwd}/../1_network/cfg/vnet_config.yml"
  config_yml=yamldecode(file(local.config_file))
  global_config_yml=yamldecode(file(local.global_config_file))

  subnets_config = local.config_yml["vnet"]["subnets"]

  vnet_name = local.config_yml["vnet"]["name"]
  create_vnet = local.config_yml["vnet"]["create"] == 1 ? true : false
  vnet_rg = local.create_vnet ? local.global_config_yml["core-rg"]["name"] : local.config_yml["vnet"]["rg"]
  vnet_cidr = local.create_vnet ? local.config_yml["vnet"]["address_space"] : null

  subnets = [
    for subnet_key, subnet_value in local.subnets_config : {
      key = subnet_key
      name = subnet_key != "gateway" ? subnet_value["name"] : "GatewaySubnet"
      cidr = local.create_vnet ? subnet_value["address_space"] : null
    }
  ]

  infra_subnet_name = local.config_yml["vnet"]["subnets"]["infra"]["name"]
  compute_subnet_name = local.config_yml["vnet"]["subnets"]["compute"]["name"]
  anf_subnet_name = try(local.config_yml["vnet"]["subnets"]["anf"]["name"], null)

  create_vpn = try( local.config_yml["vpn_gateway"]["create"] == 1 ? true : false, false ) &&  try( local.subnets_config["gateway"] != null ? true : false, false)
  vpn_prefix = local.create_vpn ? local.config_yml["vpn_gateway"]["prefix"] : null

  
}

