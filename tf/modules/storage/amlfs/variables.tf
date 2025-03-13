variable "hsm_sa" {
    description = "required details for the CycleCloud locker"
    type = object({
        storage_acct_name = string
        rg = string
        data_container_name = string
        logging_container_name = string
        import_path = string
        create_containers = optional(bool, true)
    })
    default = {
        storage_acct_name = null
        rg = null
        data_container_name = null
        logging_container_name = null
        import_path = null
        create_containers = false
    }
}

variable "name_prefix" {
    description = "prefix to append to the resources that are created"
    type = string
}

variable "location" {
    description = "location to create the resources in"
    type = string
}

variable "rg" {
    description = "name of the resource group to create the resources in"
    type = string
}

variable "sku" {
    description = "sku to use for the file system"
    type = string
}
variable "storageCapacity" {
    description = "size of the file system in TB"
    type = number
}
variable "zone" {
    description = "availability zone to create the file system in"
    type = list(string)
    default = [ "1" ]
}
variable "maintenance" {
    description = "maintenance window for the file system"
    type = object({
        dayOfWeek = string
        timeOfDay = string
    })
}

variable "enable_hsm" {
    description = "enable HSM for the file system"
    type = bool
    default = false
}

variable "vnet" {
        type = object({
        name = string
        rg  = string
        subnet = string
    })
    description = "required virtual network details"
}