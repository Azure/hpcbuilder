param storageAccountNamePrefix string
param vnetName string
param subnets array
param location string

var vnetRules = [for subnet in subnets: {
  id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnet.name)
  action: 'Allow'
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: '${storageAccountNamePrefix}${uniqueString(resourceGroup().id)}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: vnetRules
    }
  }
  
}

output vnrules array = vnetRules
