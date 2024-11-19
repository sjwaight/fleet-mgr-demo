using './main.bicep'

param fleetName = 'fleet-mgr-ignite-24'
param fleetResourceGroup = 'fleet-demo-ignite-24'
param k8sVersionOne = '1.28.10'
param k8sVersionTwo = '1.28.6'
param useHubCluster = false

var vmsize = 'Standard_D2s_v3'

param members = [
  {
    name: 'member-1-canary-azlinux'
    group: 'canary'
    dnsPrefix: 'member1'
    location: 'westcentralus'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
    kubernetesVersion: k8sVersionOne
  }
  {
    name: 'member-2-canary-win'
    group: 'canary'
    dnsPrefix: 'member2'
    location: 'australiacentral'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Windows'
    osSKU: 'Windows2022'
    windowsProfile: {
      adminUserName: 'nimda'
      adminPassword: readEnvironmentVariable('BICEP_WIN_PWD', 'P@assW0rd!N1md@')
    }
    kubernetesVersion: k8sVersionOne
  }
  {
    name: 'member-3-apac-azlinux'
    group: 'apac'
    dnsPrefix: 'member3'
    location: 'australiaeast'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSku: 'AzureLinux'
    kubernetesVersion: k8sVersionOne
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
    kubernetesVersion: k8sVersionOne
  }
  {
    name: 'member-5-apac-azlinux'
    group: 'apac'
    dnsPrefix: 'member5'
    location: 'southeastasia'
    agentCount: 2
    agentVMSize: vmsize
    osType: 'Linux'
    osSKU: 'Ubuntu'
    kubernetesVersion: k8sVersionOne
  }
]
