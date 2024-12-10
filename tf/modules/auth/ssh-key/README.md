## Terraform Module: SSH Key 

This Terraform module allows you to create an SSH key and securely store it in an Azure Key Vault.


### Usage

To use this module, include the following code in your Terraform configuration:

```hcl
module "ssh_key" {
    source              = "path/to/module"
    key_vault_name      = "my-key-vault"
    key_vault_rg            = "my-key-vault-resource-group"
}
```

### Inputs

- `keyvault_name` (required): The name of the Azure Key Vault where the SSH key will be stored.
- `keyvault_resource_group_name` (required): The name of the resource group the Azure Key vault is stored in. 
- `name_prefix` (optional): The prefix to use for the SSH key secret in the key vault. A default value of `hpcadmin` will be used to create an `hpcadmin-ssh-private-key` secret and an `hpcadmin-ssh-public-key`

```