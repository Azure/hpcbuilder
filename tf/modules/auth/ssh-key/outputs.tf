output "private_key_secret_name" {
  description = "Name of the secret that stores the private key"
  value       = azurerm_key_vault_secret.ssh_private_key.name
}

output "public_key_secret_name" {
  description = "Name of the secret that stores the public key"
  value       = azurerm_key_vault_secret.ssh_public_key.name
}

