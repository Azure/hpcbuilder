
variable "keyvault_name" {
  description = "Name of the target key vault."
  type        = string
}

variable "keyvault_resource_group_name" {
  description = "Name of the resource group where the key vault is located."
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for the SSH key secret in the key vault."
  type        = string
  default = "hpcadmin"
}