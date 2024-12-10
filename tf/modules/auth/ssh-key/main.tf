
# Azure Key Vault

data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resource_group_name
}

resource "tls_private_key" "privsshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "${var.name_prefix}-ssh-private-key"
  value        = tls_private_key.privsshkey.private_key_pem
  key_vault_id = data.azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "${var.name_prefix}-ssh-public-key"
  value        = tls_private_key.privsshkey.public_key_openssh
  key_vault_id = data.azurerm_key_vault.kv.id
}