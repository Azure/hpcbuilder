# Azure HPC Builder
## Compute Configuration 
Note, if you are planning to create resources using this stage, you will need to populate the:
- [base_config.yml](../0_base/cfg/base_config.yml). Instructions can be found in the [ReadMe](../0_base/ReadMe.md) for that stage.
- [vnet_config.yml](../1_network/cfg/vnet_config.yml). Instructions can be found in the [ReadMe](../1_network/ReadMe.md) for that stage.
- [storage_config.yml](../2_storage/cfg/storage_config.yml). Instructions can be found in the [ReadMe](../2_storage/ReadMe.md) for that stage. 
- [compute_config.yml](./cfg/compute_config.yml) 

> IMPORTANT: This step requires that the identity used to deploy resources against Azure has the ability to create role assignments

## Installation 

1. If you don't already have it, [install Terraform](https://developer.hashicorp.com/terraform/install) and the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. [Sign into Azure with the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli) 

## Deployment

1. Populate the [compute_config.yml](./cfg/compute_config.yml) file. The configuration requires the:
    - **prefix** to use for the creation of the VM components, e.g., the nic, disk, etc
    - **SKU** size for the CycleCloud VM 
    - **Image type**: can be marketplace or custom
    - **Image details**: In the case of a marketplace image, the publiser, offer, and sku must be associated with an Alma Linux or Ubuntu image
    - **ID**: In the case of a custom image, the resource id of the image
    - **OS Type**: Alma Linux-based and Ubuntu-based operating systems are supported
    - **CycleCloud version**: supported versions are 8.6.0 - 8.6.5 

Below is an example configuration:    

```
cyclecloud:
  name_prefix: cycle
  vm_size: Standard_D4as_v4
  version: 8.6.5
  image:
    type: marketplace # or custom
    publisher: almalinux
    offer: almalinux-x86_64
    sku: 8_7-gen2
    version: latest
    os_type: alma

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

This step creates a VM with an attached managed disk. The desired image is applied on the VM and a VM extension is used to install CycleCloud. The VM is created against the infra subnet defined in the [vnet_config.yml](../1_network/cfg/vnet_config.yml) in the flex resource group defined in the [base_config.yml](../0_base/cfg/base_config.yml). The VM is granted the: 
- Contributor role against the resource group of the vnet defined in [vnet_config.yml](../1_network/cfg/vnet_config.yml)
- Contributor role against the resource group where the VM is created, i.e., the flex resource group defined in the [base_config.yml](../0_base/cfg/base_config.yml)
- Storage Account Contributor against the storage account defined in [storage_config.yml](../2_storage/cfg/storage_config.yml)
- Storage Blob Data Contributor against the storage account defined in [storage_config.yml](../2_storage/cfg/storage_config.yml)


## Notes
- The VM is deployed with no public IP. To connect to the CycleCloud VM an existing express route or VPN connection can be used. Optionally, this framework includes the capability to create a VPN Gateway to be able to connect to the VM via private IP, but this is not recommended for production scenarios. 
- Once you connect to the CycleCloud VM, you will need to configure CycleCloud. Please note: 
    - To populate the details of the CycleCloud admin account, use the credentials stored in the key vault defined in [base_config.yml](../0_base/cfg/base_config.yml) 
    - Use the storage account defined in [storage_config.yml](../2_storage/cfg/storage_config.yml) to create the CycleCloud locker
    - Ensure clusters use the compute subnet defined in [vnet_config.yml](../1_network/cfg/vnet_config.yml)


