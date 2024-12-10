output "cycle_config" {  
    value = {
        prefix = local.cycle_config.name_prefix
        version = local.cycle_version
        vm_size = local.cycle_config.vm_size
    }
}

output "cycle_image" {
    value = {
        os_type = local.cycle_config.image.os_type
        publisher = local.cycle_config.image.publisher
        offer = local.cycle_config.image.offer
        sku = local.cycle_config.image.sku
        type = local.cycle_config.image.type
        id = local.custom_image
    }
}