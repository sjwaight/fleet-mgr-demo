param clustersResourceGroup string
param parentFleet resource 'Microsoft.ContainerService/fleets@2024-04-01'
param tags object
param member object = {
  name: 'member-1-euap-azlinux'
  group: 'canary'
  dnsPrefix: 'member1'
  location: 'eastus2euap'
  agentCount: 2
  agentVMSize: 'Standard_D2s_v3'
  osType: 'Linux'
  osSku: 'AzureLinux'
  kubernetesVersion: '1.29.2'
}

module clusterResource './cluster.bicep' = {
  scope: resourceGroup(clustersResourceGroup)
  name: member.name
  params: {
    tags: tags
    member: member
  }
}

resource fleet 'Microsoft.ContainerService/fleets@2024-04-01' existing = {
  name: parentFleet.name
  scope: resourceGroup()
}

resource members_resource 'Microsoft.ContainerService/fleets/members@2024-04-01' = {
  parent: fleet
  name: member.name
  properties: {
    clusterResourceId: clusterResource.outputs.cluster.clusterId
    group: member.group
  }
}


