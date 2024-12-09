targetScope = 'subscription'
param vnetName string
param vnetAddressSpace string
param subnets array
param location string
param resourceGroupName string
param storageAccountNamePrefix string


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module network '1_network/network.bicep' = {
  name: 'networkModule'
  params: {
    vnetName: vnetName
    vnetAddressSpace: vnetAddressSpace
    subnets: subnets
    location: location
  }
  scope: resourceGroup
}


module storage '2_storage/storage.bicep' = {
  name: 'storageModule'
  params: {
    storageAccountNamePrefix: storageAccountNamePrefix
    vnetName: network.outputs.vnet_name
    subnets: subnets
    location: location
  }
  scope: resourceGroup
  dependsOn: [
    network
  ]
}


output storageAccountNetworkRules array = storage.outputs.vnrules
output subnets array = network.outputs.subnet_details
output storageVnetRules array = storage.outputs.vnrules
