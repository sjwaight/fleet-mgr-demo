# Long running monitoring

## Deployment

```bash
SUBSCRIPTION_ID='359833f5-8592-40b6-8175-edc664e2196a'
az deployment sub create \
--name "fleet-mgr-$(date -I)" \
--location australiaeast \
--subscription ${SUBSCRIPTION_ID} \
--template-file main.bicep \
--parameters main.bicepparam
```

### Overview

The solution includes the following resources:  
- fleet resource group: flt-demo
- clusters resource group: flt-demo-clusters

- hubless fleet: `/subscriptions/<subscription>/resourceGroups/flt-demo/providers/Microsoft.ContainerService/fleets/fleet-mgr`

4 clusters across different regions:  
- 2 x westcentralus (azlinux, windows)
- 1 x northeurope (azlinux)
- 1 x australiaeast (azlinux)

see [cluster.bicep](./cluster.bicep) for more details on their configuration.
see [main.bicepparams.json](./main.bicepparams.json) for the parameters used to deploy the resources

The clusters are joined to the fleet, with `staging`, `europe` and `latam` groups.

2 update strategies:  
- `fast`: [all]
- `staged`: [euap][europe, latam]

2 autoupgrade profiles:  
- k8s rapid, with `staged` strategy
- node image, with `fast` strategy
