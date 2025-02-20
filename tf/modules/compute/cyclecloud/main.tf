data "azurerm_subscription" "primary" {
}

data "azurerm_resource_group" "cycle_rg" {
    name = var.resource_group_name
}

data "azurerm_resource_group" "vnet_rg" {
  name = var.vnet.rg
}

data "azurerm_virtual_network" "vnet" {
    name                = var.vnet.name
    resource_group_name = var.vnet.rg
}

data "azurerm_subnet" "cycle_subnet" {
  name                 = var.vnet.subnet 
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
}

data "azurerm_storage_account" "locker" {
  name                = var.locker.storage_acct_name
  resource_group_name = var.locker.rg
}

data "azurerm_role_definition" "contributor" {
  name = "Contributor"
}

data "azurerm_role_definition" "reader" {
  name = "Reader"
}

data "azurerm_role_definition" "blob_data_contributor" {
  name = "Storage Blob Data Contributor"
}

data "azurerm_role_definition" "storage_acct_contributor" {
  name = "Storage Account Contributor"
}

data "azurerm_role_definition" "blob_data_reader" {
  name = "Storage Blob Data Reader"
}

resource "azurerm_network_interface" "cycle_nic" {
  name                = "${var.name_prefix}-nic"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_resource_group.cycle_rg.name

  ip_configuration {
    name                          = "cycle-nic-ip"
    subnet_id                     = data.azurerm_subnet.cycle_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "cycle_vm" {
  name                  = "${var.name_prefix}-vm"
  location              = data.azurerm_virtual_network.vnet.location
  resource_group_name   = data.azurerm_resource_group.cycle_rg.name
  network_interface_ids = [azurerm_network_interface.cycle_nic.id]
  size               = var.vm_size
  admin_username = var.admin.username

    admin_ssh_key {
        username   = var.admin.username
        public_key = var.admin.public_key
    }

    identity {
        type = "SystemAssigned"
    }
  
    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

  dynamic "source_image_reference" {
    for_each = var.use_image_id ? [] : [1]
    content {
      publisher = var.image.publisher
      offer     = var.image.offer
      sku       = var.image.sku
      version   = var.image.version 
    }
  }
  source_image_id = var.use_image_id ? var.image_id : null
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.name_prefix}-data"
  location             = azurerm_linux_virtual_machine.cycle_vm.location
  resource_group_name  = azurerm_linux_virtual_machine.cycle_vm.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 128
}

resource "azurerm_virtual_machine_data_disk_attachment" "cc_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_linux_virtual_machine.cycle_vm.id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_run_command" "install_run_cmd" {
  name                = "${var.name_prefix}-install"
  location            = azurerm_linux_virtual_machine.cycle_vm.location
  virtual_machine_id  = azurerm_linux_virtual_machine.cycle_vm.id

  source {
    script = templatefile("${path.module}/templates/${var.operating_system}.tfpl", { cycle_version = var.cc_version })
  }

  depends_on = [azurerm_virtual_machine_data_disk_attachment.cc_disk_attachment]
}

# create a new vm extension that executes after the run command to configure cyclecloud
resource "azurerm_virtual_machine_extension" "configure" {
  name = "${var.name_prefix}-configure"
  virtual_machine_id = azurerm_linux_virtual_machine.cycle_vm.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"

  protected_settings = <<PROT
  {
    "script": "${base64encode(templatefile("${path.module}/templates/configure.tfpl", {
    cycle_admin = var.admin.username,
    cycle_pw = var.admin.password,
    cycle_pubkey = chomp(var.admin.public_key),
    cycle_sa = var.locker.storage_acct_name,
    cycle_identity = azurerm_user_assigned_identity.cluster_identity.id
      }) )}"
  }
  PROT

  depends_on = [ azurerm_virtual_machine_run_command.install_run_cmd ]
}


# create a user assigned identity
resource "azurerm_user_assigned_identity" "cluster_identity" {
  name                = "${var.name_prefix}-cluster-identity"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_resource_group.cycle_rg.name
}

# Grant storage blob data reader access to the locker
resource "azurerm_role_assignment" "locker_blob_reader" {
  scope              = data.azurerm_storage_account.locker.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.blob_data_reader.id}"
  principal_id       = azurerm_user_assigned_identity.cluster_identity.principal_id
}

# Grant Contributor access to CycleCloud VM to the target resource group
resource "azurerm_role_assignment" "cycle_rg_ra" {
    scope              = data.azurerm_resource_group.cycle_rg.id
    role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.contributor.id}"
    principal_id       = azurerm_linux_virtual_machine.cycle_vm.identity[0].principal_id
}

# Grant Contributor access to cyclecloud vm in the vnet resource group
resource "azurerm_role_assignment" "vnet_rg_ra" {
  count = data.azurerm_resource_group.vnet_rg.name != data.azurerm_resource_group.cycle_rg.name ? 1 : 0
  scope              = data.azurerm_resource_group.vnet_rg.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.contributor.id}"
  principal_id       = azurerm_linux_virtual_machine.cycle_vm.identity[0].principal_id
}

# Grant Subscription Reader access to cyclecloud vm
resource "azurerm_role_assignment" "cycle_sub_ra" {
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.reader.id}"
  principal_id       = azurerm_linux_virtual_machine.cycle_vm.identity[0].principal_id
}

# Grant Storage Blob Data Contributor access to the storage account
resource "azurerm_role_assignment" "locker_blob_ra" {
  scope              = data.azurerm_storage_account.locker.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.blob_data_contributor.id}"
  principal_id       = azurerm_linux_virtual_machine.cycle_vm.identity[0].principal_id
}

# Grant Storage Account Contributor access to the storage account
resource "azurerm_role_assignment" "locker_sa_ra" {
  scope              = data.azurerm_storage_account.locker.id
  role_definition_id = "${data.azurerm_subscription.primary.id}${data.azurerm_role_definition.storage_acct_contributor.id}"
  principal_id       = azurerm_linux_virtual_machine.cycle_vm.identity[0].principal_id
}

#resource "local_file" "install_script" {
#    content  = templatefile("${path.module}/templates/${var.operating_system}.tfpl", {cycle_version = var.cc_version})
#    filename = "${path.module}/install.sh"
#}

#resource "local_file" "configure_script" {
#    content  = templatefile("${path.module}/templates/configure.tfpl", 
#    {
#        cycle_admin = var.admin.username,
#        cycle_pw = var.admin.password,
#        cycle_pubkey = var.admin.public_key,
#        cycle_sa = var.locker.storage_acct_name
#        cycle_identity = azurerm_user_assigned_identity.cluster_identity.id 
#          })
#    filename = "${path.module}/configure.sh"
#}
