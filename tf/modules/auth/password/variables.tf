# Input variable definitions

variable "keyvault_name" {
  description = "Name of the target key vault."
  type        = string
}

variable "keyvault_resource_group_name" {
  description = "Name of the resource group where the key vault is located."
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for the password secret in the key vault."
  type        = string
  default = "hpcadmin"
}

variable "length" {
  description = "Length of the generated password."
  type        = number
  default = 16
  validation {
    condition = var.length >= 8 && var.length <= 123
    error_message = "Password length must be between 8 and 123 characters."
  }
}


