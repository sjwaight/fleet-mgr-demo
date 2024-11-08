targetScope='subscription'

param fleetName string = 'fleet-mgr'
param fleetLocation string = 'westcentralus'
param tags object = {
  environment: 'test'
  owners: 'fleet'
  'aks-node-os-auto-upgrade-exception': 'true'
}
param vmsize string = 'Standard_D2s_v3'
param fleetResourceGroup string = 'fleet-demo'
param clustersResourceGroup string = '${fleetResourceGroup}-clusters'

// this gets overriden by the values in main.bicepparam
param members array = [
  {
    name: 'member-1-canary-azlinux'
    group: 'canary'
    dnsPrefix: 'member1'
    location: 'eastus2'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
    windowsProfile: null
  }
  {
    name: 'member-2-canary-win'
    group: 'canary'
    dnsPrefix: 'member2'
    location: 'eastus2'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Windows'
    osSKU: 'Windows2022'
    windowsProfile: {
      adminUserName: ''
      adminPassword: ''
    }
  }
  {
    name: 'member-3-latam-azlinux'
    group: 'anz'
    dnsPrefix: 'member3'
    location: 'australiaeast'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
    windowsProfile: null
  }
  {
    name: 'member-4-eu-azlinux'
    group: 'europe'
    dnsPrefix: 'member4'
    location: 'northeurope'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSKU: 'AzureLinux'
    windowsProfile: null
  }
]

resource fltRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: fleetResourceGroup
  location: fleetLocation
}

resource clustersRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: clustersResourceGroup
  location: fleetLocation
}

module fleet './fleet.bicep' = {
  scope: resourceGroup(fltRG.name)
  name: fleetName
  params: {
    name: fleetName
    location: fleetLocation
    tags: tags
  }
}

module member_clusters './member.bicep' =[for member in members: {
  scope: resourceGroup(fltRG.name)
  name: '${member.name}-module'
  params: {
    tags: tags
    clustersResourceGroup: clustersResourceGroup
    parentFleet: fleet.outputs.fleet
    member: member
  }
}]
