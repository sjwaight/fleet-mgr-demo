# Azure Kubernetes Fleet Demo 

Recommendation is to select two patches from the same minor release if you wish to test Rapid *or* Stable channels.

If you wish to test out safety of update runs with breaking minor version upgrades, first identify any deprecated APIs between releases.

You must have the [Azure CLI installed](https://learn.microsoft.com/cli/azure/install-azure-cli), and access to an Azure Subscription with appropriate permissions.

## Deployment

Determine appropriate/available Kubernetes version(s) to use with your demo setup.

```bash
az aks get-versions --location eastus --output table
```

Modify the `main.bicepparam` file and update the `k8sVersionOne` and `k8sVersionTwo` parameters accordingly. They can be set the same if you wish.

Set the following variables.

```bash
export BICEP_WIN_PWD="..."
export SUBSCRIPTION_ID='...'
export FLEET_LOCATION="australiaeast"
```

Invoke the shell script

```bash
./deploy.sh
```

or use the following Azure CLI deployment command:

```bash
az deployment sub create \
--name "fleet-mgr-$(date -I)" \
--location ${FLEET_LOCATION} \
--subscription ${SUBSCRIPTION_ID} \
--template-file main.bicep \
--parameters main.bicepparam
```

> [!NOTE]  
> You can deploy a fleet with a hub cluster by editing the `main.bicepparam` file and setting `useHubCluster` to `true`.

### Overview

The solution includes the following resources:
  
- fleet resource group: flt-demo
- clusters resource group: flt-demo-clusters

- hubless fleet: `/subscriptions/<subscription>/resourceGroups/flt-demo/providers/Microsoft.ContainerService/fleets/fleet-mgr`

5 clusters across different regions:  

- 1 x australiaeast (windows)
- 1 x westcentralus (azlinux)
- 1 x northeurope (azlinux)
- 1 x australiaeast (azlinux)
- 1 x southeastasia (azlinux)

see [cluster.bicep](./cluster.bicep) for more details on their configuration.
see [main.bicepparams](./main.bicepparam) for the parameters used to deploy the resources

The clusters are joined to the fleet, with `staging`, `europe` and `latam` groups.

2 update strategies:  

- `fast`: [all]
- `staged`: [euap],[europe, latam]

2 autoupgrade profiles:  

- k8s rapid, with `staged` strategy
- node image, with `fast` strategy

### Test upgrade failure scenario

The current scenario works with shifts from Kubernetes 1.28 to 1.29. You can replicate for newer releases by identifying deprecated/removed APIs and invoking them.

Authenticate kubectl as admin to one of the member clusters created and either issue the below command or deploy the [sample YAML](samples/test-deprecated-api.yaml).

```bash
az aks get-credentials --admin -n ${ClUSTER_NAME} -g ${RG_NAME}

kubectl get --raw /apis/flowcontrol.apiserver.k8s.io/v1beta2/prioritylevelconfigurations
```

Check use of deprecated API

```bash
kubectl get --raw /metrics | grep apiserver_requested_deprecated_apis
```

```bash
# HELP apiserver_requested_deprecated_apis [STABLE] Gauge of deprecated APIs that have been requested, broken out by API group, version, resource, subresource, and removed_release.
# TYPE apiserver_requested_deprecated_apis gauge
apiserver_requested_deprecated_apis{group="externaldata.gatekeeper.sh",removed_release="",resource="providers",subresource="",version="v1alpha1"} 1
apiserver_requested_deprecated_apis{group="flowcontrol.apiserver.k8s.io",removed_release="1.29",resource="prioritylevelconfigurations",subresource="",version="v1beta2"} 1
```

> [!NOTE]  
> Wait at least 60 minutes before attempting to perform an update run on the member clusters that shifts from 1.28 to 1.29. The cluster will not be updated and will remain operational, and the update run will be halted.
