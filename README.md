# Fleet Demo Deployment

## Deployment

```bash
export BICEP_WIN_PWD="..."
export SUBSCRIPTION_ID='...'
export FLEET_LOCATION="australiaeast"
./deploy.sh
```

or use the following az deployment command:

```bash
az deployment sub create \
--name "fleet-mgr-$(date -I)" \
--location ${FLEET_LOCATION} \
--subscription ${SUBSCRIPTION_ID} \
--template-file main.bicep \
--parameters main.bicepparam
```

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
- `staged`: [euap][europe, latam]

2 autoupgrade profiles:  
- k8s rapid, with `staged` strategy
- node image, with `fast` strategy
