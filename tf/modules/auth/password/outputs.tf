
output "secret-name" {
  description = "Name of the secret"
  value       = resource.azurerm_key_vault_secret.password.name
}