# Azure HPC Builder
## Base Configuration 
To start your deployment with Azure HPC Builder, you will need to populate the base configuration. 

## Installation 

1. If you don't already have it, [install Terraform](https://developer.hashicorp.com/terraform/install) and the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. [Sign into Azure with the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli) 

## Deployment

1. Populate the [base_config.yml](./cfg/base_config.yml) file. The base configuration requires: 
    - A name to create two Resource Groups: 
        - **core-rg**: The resource group that will store resources that will become more critical over time and should not be destroyed. For example
            - Virtual Networks
            - Storage Accounts
            - ANF
            - Key Vault
            - Image Gallery

        - **flex-rg**: The resource group that will store resources that may need to be rebuilt or re-deployed at some point in the future due to upgrades. For example: 
            - CycleCloud VM
            - Additional Infrastructure VMs (e.g. login VMs, license VMs, etc)
            - Scale Sets 
            - Azure Managed Lustre
    - A name to create a key vault
        - The key vault will be used to store a randomly generated password and ssh keys for the admin account 
    - An admin username 
        - the username will be used as prefix to store the secrets that consist of the password and ssh keys

Below is an example configuration:    

```
location: eastus

core-rg:
  name: hpcbuilder-core-rg

flex-rg:
  name: hpcbuilder-flex-rg

keyvault:
  name: hpcbuilder-kv

admin:
  username: hpcadmin

```

2. Initialize your terraform configuration
```
terraform init 
```
3. *Optional* Preview the configuraiton 
```
terraform plan
```
4. Apply the configuration 
```
terraform apply
```

This step creates 2 resource groups and a key vault which includes the following secrets: 
- a secret for the admin password
- a secret for the admin ssh private key
- a secret for the admin ssh public key


## Notes
- The inputs in the base_config.yml are shared as terraform outputs to the later stages in order to enable the creation of additional required infrastructure. For example, the core-rg name is shared as a terraform output to determine where a vnet should be created.  



