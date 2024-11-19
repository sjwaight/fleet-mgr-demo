param name string
param tags object
param location string = resourceGroup().location
param useHubCluster bool = false

resource fleetResource 'Microsoft.ContainerService/fleets@2024-04-01' = {
  name: name
  tags: tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hubProfile: useHubCluster ? {
      agentProfile: {}
      apiServerAccessProfile: {
        enablePrivateCluster: false
      }
    } : {}
  }
}

resource updateStrategy_staged 'Microsoft.ContainerService/fleets/updateStrategies@2024-04-01' = {
  parent: fleetResource
  name: 'staged'
  properties: {
    strategy: {
      stages:[
        {name: 'canary', groups: [{name: 'canary'}], afterStageWaitInSeconds: 3600 }
        {name: 'prod', groups: [{name: 'apac'}, {name: 'europe'}]}
      ]
    }
  }
}

resource updateStrategy_fast 'Microsoft.ContainerService/fleets/updateStrategies@2024-04-01' = {
  parent: fleetResource
  name: 'fast'
  properties: {
    strategy: {
      stages:[
        {name: 'prod', groups: [ {name: 'canary'}, {name: 'apac'}, {name: 'europe'}]}
      ]
    }
  }
}

resource autoupgradeProfile_k8s_rapid 'Microsoft.ContainerService/fleets/autoUpgradeProfiles@2024-05-02-preview' = {
  parent: fleetResource
  name: 'k8slatest-staged'
  properties: {
    channel: 'Rapid'
    nodeImageSelection: {
        type: 'Consistent'
    }
    updateStrategyId: updateStrategy_staged.id
  }
}

resource autoupgradeProfile_nodeimage_rapid 'Microsoft.ContainerService/fleets/autoUpgradeProfiles@2024-05-02-preview' = {
  parent: fleetResource
  name: 'nodeimage-fast'
  properties: {
    channel: 'NodeImage'
    updateStrategyId: updateStrategy_fast.id
  }
}

output fleet resource 'Microsoft.ContainerService/fleets@2024-04-01' = fleetResource
