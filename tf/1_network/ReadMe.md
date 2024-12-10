# Azure HPC Builder
## VNET Configuration 
This stage can simply refer to existing resources. Note, if you are planning to create resources using this stage, you will need to populate the [base_config.yml](../0_base/cfg/base_config.yml) and the [vnet_config.yml](./cfg/vnet_config.yml). Instructions to populate and deploy the resources for the `base_config.yml` can be found in the [ReadMe](../0_base/ReadMe.md) for that stage.   

## Installation 

1. If you don't already have it, [install Terraform](https://developer.hashicorp.com/terraform/install) and the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
2. [Sign into Azure with the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli) 

## Deployment

1. Populate the [vnet_config.yml](./cfg/vnet_config.yml) file. The vnet configuration requires: 
    - A vnet with a minimum of two subnets: 
        - **infra**: A subnet for insfrastructure VMs. For example, the CycleCloud VM would be placed on this subnet. 
        - **compute**: A subnet for the compute VMs. You can configure CycleCloud to use this subnet for the node arrays that are defined in the clusters.

      The following **optional** subnets can be added: 
        - **gateway**: A subnet for deploying a VPN gateway. This subnet will be named `GatewaySubnet`. The subnet is only required if you are deploying a VPN gateway.  

      Additional subnets can be added with the format of:
      ```
      UNIQUE_KEY:  
        address_space: ADDRESS_SPACE  
        name: NAME
      ```

Below is an example configuration to create a vnet with a VPN gateway:    
```
vnet:
  address_space: 10.2.0.0/16
  create: 1
  name: hpc-vnet
  subnets:
    compute:
      address_space: 10.2.0.0/23
      name: compute
    infra:
      address_space: 10.2.2.0/25
      name: infra
    gateway: #optional subnet, but required to create the VPN Gateway
      address_space: 10.2.2.128/27

# This should only be deployed for testing purposes. For production use cases, an ALZ should be in place.
vpn_gateway:
  create: 1
  prefix: hpc
```

Below is an example configuration to use an existing vnet:    
```
vnet:
  create: 0
  rg: myvnetrg
  name: existing-hpc-vnet
  subnets:
    compute:
      name: compute
    infra:
      name: infra
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

This stage can be used to create the following components: 
 - A vnet with a minimum of 2 subnets that have service endpoints to Microsoft.Storage
 - A VPN Gateway - the deployment of this component is only recommended for testing  


## Notes
- The inputs in the vnet_config.yml are shared as terraform outputs to the later stages in order to enable the creation of additional required infrastructure. For example, the CycleCloud VM is deployed against the infra subnet.
- If using an existing vnet, it is assumed that the defined subnets are already included in the existing vnet. This component does not create subnets against an existing vnet.  


