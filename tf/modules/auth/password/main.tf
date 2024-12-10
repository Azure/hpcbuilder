# Azure Key Vault
data "azurerm_key_vault" "kv" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resource_group_name
}

resource "random_password" "password" {
  length = var.length
  numeric = true
  upper = true 
  special = true
  min_lower = 1
  min_upper = 1
  min_special = 1
  min_numeric = 1
  
  override_special = "@#$%^&*-_!+=[]{}|\\:',.?~\"();" 
}

resource "azurerm_key_vault_secret" "password" {
  name         = "${var.name_prefix}-pw"
  value        = random_password.password.result
  key_vault_id = data.azurerm_key_vault.kv.id
}