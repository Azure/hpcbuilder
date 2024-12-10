# Azure HPC Builder
## Storage Configuration 
Note, if you are planning to create resources using this stage, you will need to populate the:
- [base_config.yml](../0_base/cfg/base_config.yml). Instructions can be found in the [ReadMe](../0_base/ReadMe.md) for that stage.
- [vnet_config.yml](../1_network/cfg/vnet_config.yml). Instructions can be found in the [ReadMe](../1_network/ReadMe.md) for that stage.
- [storage_config.yml](./cfg/storage_config.yml) 


## Installation 

1. If you don't already have it, [install Terraform](https://developer.hashicorp.com/terraform/install) and the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. [Sign into Azure with the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli) 

## Deployment

1. Populate the [storage_config.yml](./cfg/storage_config.yml) file. The base configuration requires the name of a storage account. The storage account is assumed to be used as the CycleCloud locker.   
    

Below is an example configuration:    

```
cyclecloud_locker:
  name: hpcbuilderdemolocker

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

This step creates a storage account that can only be accessed from the infra and compute subnets defined in the [vnet_config.yml](../1_network/cfg/vnet_config.yml) from stage [1_network](../1_network/)


## Notes
- The inputs in the storage_config.yml are shared as terraform outputs to the later stages in order to enable the creation of additional required infrastructure. For example, the CycleCloud VM is given a role assignment so that it can create a container against the storage account. 


