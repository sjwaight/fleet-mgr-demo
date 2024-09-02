# Description: Deploys the Bicep template to Azure
az deployment sub create \
  --name "fleet-mgr-$(date -I)" \
  --location "${FLEET_LOCATION}" \
  --subscription ${SUBSCRIPTION_ID} \
  --template-file main.bicep \
  --parameters main.bicepparam