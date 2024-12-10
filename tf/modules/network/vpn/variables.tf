# Input variable definitions
variable "name_prefix" {
  description = "Prefix for naming the resources deployed by this module"
  type        = string
  default = "azhpcbuilder"
}
variable "resource_group_name" {
  description = "Name of the target resource group."
  type        = string
}

variable "vnet" {
        type = object({
        name = string
        rg  = string
    })
    description = "required virtual network details"
}

variable "point2site_address_pool" {
  type        = list(string)
  default     = ["172.16.0.0/24"]
  description = "Address pool for point-to-site VPN."  
}

variable "aad_audience" {
  type        = string
  description = "AAD audience."
  default = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
}

