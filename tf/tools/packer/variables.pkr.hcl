variable "subscription_id" {
  description = "The subscription ID for the Azure account."
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group."
  type        = string
}

variable "gallery_name" {
  description = "The name of the shared image gallery."
  type        = string
}

variable "image_name" {
  description = "The name of the image in the shared image gallery."
  type        = string
}

variable "image_version" {
  description = "The version of the image in the shared image gallery."
  type        = string
}

variable "vnet" {
  description = "The name of the virtual network."
  type        = string
}

variable "subnet" {
  description = "The name of the subnet in the virtual network."
  type        = string
}

variable "vnet_rg_name" {
  description = "The name of the resource group containing the virtual network."
  type        = string
}

variable "ssh_user" {
  description = "The SSH username for the virtual machine."
  type        = string
}

variable "private_key" {
  description = "The path to the private SSH key file."
  type        = string
}

variable "managed_image_name" {
  description = "The name of the managed image."
  type        = string
}

variable "replication_regions" {
  description = "The regions where the image will be replicated."
  type        = list(string)
  default     = []
}

variable "os_type" {
  type    = string
  default = null
}