param vnetName string
param vnetAddressSpace string
param subnets array
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
  }
}
resource subs 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = [for (sn, index) in subnets: {
  name: sn.name
  parent: vnet
  properties: {
    addressPrefix: sn.addressPrefix
    serviceEndpoints: [
      {
      service: 'Microsoft.Storage'
      locations: [
        location
      ]
      }
    ]
    }
    
  }]

output resource_group_name string = resourceGroup().name
output vnet_name string = vnetName
output vnet_cidr string = vnetAddressSpace
output subnet_details array = [for sn in subnets: {
  name: sn.name
  addressPrefix: sn.addressPrefix
  details: 'Subnet Name: ${sn.name}, Address Prefix: ${sn.addressPrefix}'
}]


