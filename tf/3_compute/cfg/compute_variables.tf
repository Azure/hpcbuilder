locals {

  versions = {
    "8" = {
      cycle_version = "8.6.5-3340"
    }
    "8.6.5" = {
      cycle_version = "8.6.5-3340"
    }
    "8.6.4" = {
      cycle_version = "8.6.4-3320"       
    }
    "8.6.3"= {
      cycle_version = "8.6.3-3293"
    }
    "8.6.2" = {
      cycle_version = "8.6.2-3276" 
    }
    "8.6.1" = {
      cycle_version = "8.6.1-3248"
    }
    "8.6.0"= {
      cycle_version = "8.6.0-3223"
    }
  }
  config_file="${path.cwd}/../3_compute/cfg/compute_config.yml"
  config_yml=yamldecode(file(local.config_file))

  cycle_config = local.config_yml["cyclecloud"]

  version_input = try(local.cycle_config["version"], 8) 
  cycle_version = local.versions[local.version_input]["cycle_version"]

  custom_image = try(local.cycle_config["custom_image"], null)

  



  
}