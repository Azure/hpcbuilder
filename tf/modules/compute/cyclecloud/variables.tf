variable "name_prefix" {
  description = "Prefix for naming cyclecloud VM and associated resources (i.e., nic, disk, etc)."
  type        = string
  
}

variable "image" {
    description = "The image to use for the virtual machine."
    type        = object({
        publisher = string
        offer     = string
        sku       = string
        version   = optional(string, "latest")
    })
    default = {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts-gen2"
      version = "latest"
    }
}

variable "operating_system" {
  description = "type of linux OS that will be used"
  type = string
  default = "ubuntu"
    validation {
    condition     = contains(["ubuntu", "alma"], var.operating_system)
    error_message = "Valid values for var: operating_system are (ubuntu, alma)."
  }
}

variable "cc_version" {
  description = "cyclecloud version to install on the vm"
  type = string
  default = "8.7.1-3364"
  validation {
    condition     = contains(["8.7.1-3364"], var.cc_version)
    error_message = "Valid values for var: occ_version are: 8.7.1-3364"
  }
}

variable "use_image_id" {
    description = "Use an image ID instead of the image reference."
    type        = bool
    default     = false
}

variable "image_id" {
    description = "ID of the image to use for the virtual machine."
    type        = string
    default = null
}

variable "resource_group_name" {
  description = "Name of the target resource group."
  type        = string
}

variable "admin" {
        type = object({
        username = optional(string, "hpcadmin")
        public_key  = string
        password = string
    })
    description = "details of admin account - username of hpcadmin is default"
}

variable "vnet" {
        type = object({
        name = string
        rg  = string
        subnet = string
    })
    description = "required virtual network details"
}

variable "vm_size" {
  description = "Size of the virtual machine."
  type        = string
  default     = "Standard_D4as_v4"
  
}

variable "locker" {
    description = "required details for the CycleCloud locker"
    type = object({
        storage_acct_name = string
        rg = string
    })
}