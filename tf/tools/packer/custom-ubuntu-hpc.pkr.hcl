source "azure-arm" "azure-hpc-img" {
  use_azure_cli_auth = true

  # USE MARKETPLACE IMAGE AS SOURCE
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_publisher = "canonical"
  image_sku       = "22_04-lts-gen2"
  image_version   = "latest"

  # USE SHARED GALLERY AS SOURCE
  # shared_image_gallery {
  #   subscription   = "${var.subscription_id}"
  #   resource_group = "${var.rg_name}"
  #   gallery_name   = "${var.sig_name}"
  #   image_name     = "${var.image_name}"
  #   image_version  = "${var.source_image_version}"
  # }

  os_type = "${var.os_type}"
  vm_size = "Standard_DS2_v2"

  # IN CASE DISK SIZE NEEDS TO BE BIGGER FOR INSTALLED PACKAGES
  # os_disk_size_gb = 128

  shared_image_gallery_destination {
    subscription  = "${var.subscription_id}"
    gallery_name  = "${var.gallery_name}"
    image_name    = "${var.image_name}"
    image_version = "${var.image_version}"
    # replication_regions = ["${var.replication_regions}"]
    resource_group       = "${var.rg_name}"
    storage_account_type = "Premium_LRS"
  }
  # shared_image_gallery_replica_count = 1

  managed_image_name                 = "${var.managed_image_name}"
  managed_image_resource_group_name  = "${var.rg_name}"
  managed_image_storage_account_type = "Premium_LRS"

  build_resource_group_name           = "${var.rg_name}"
  virtual_network_name                = "${var.vnet}"
  virtual_network_subnet_name         = "${var.subnet}"
  virtual_network_resource_group_name = "${var.vnet_rg_name}"
  ssh_pty                             = "true"
  ssh_username                        = "${var.ssh_user}"
  ssh_private_key_file                = "${var.private_key}"
}

build {
  sources = ["source.azure-arm.azure-hpc-img"]


  provisioner "file" {
    source      = "scripts/"
    destination = "/tmp"
  }

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "chmod +x /tmp/*.sh",
      "/tmp/configure.sh || exit 1",
      "/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync",
      "sed -i 's/^send host-name =.*/send host-name = \"\"/' /etc/dhcp/dhclient.conf",
      "export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
    skip_clean     = true
  }
}
