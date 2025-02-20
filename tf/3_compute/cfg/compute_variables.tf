locals {

  versions = {
    "8" = {
      cycle_version = "8.7.1-3364"
    }
    "8.7.1" = {
      cycle_version = "8.7.1-3364"
    }
  }
  config_file="${path.cwd}/../3_compute/cfg/compute_config.yml"
  config_yml=yamldecode(file(local.config_file))

  cycle_config = local.config_yml["cyclecloud"]

  version_input = try(local.cycle_config["version"], 8) 
  cycle_version = local.versions[local.version_input]["cycle_version"]

  custom_image = try(local.cycle_config["custom_image"], null)

  



  
}