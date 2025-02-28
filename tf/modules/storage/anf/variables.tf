variable "name_prefix" {
  description = "Prefix for naming the ANF Volume and associated resources."
  type        = string
  
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "vnet" {
        type = object({
        name = string
        rg  = string
        subnet = string
    })
    description = "required virtual network details"
}

variable "ntap_pool_service_level" {
  description = "Service level for the NetApp pool."
  type        = string
}

variable "ntap_pool_size_in_tb" {
  description = "Size of the NetApp pool in TB."
  type        = number
}

variable "ntap_volume_name" {
  description = "Name of the NetApp volume."
  type        = string
}

variable "ntap_volume_path" {
  description = "Path for the NetApp volume."
  type        = string
}

variable "ntap_volume_size_in_gb" {
  description = "Size of the NetApp volume in GB."
  type        = number
}