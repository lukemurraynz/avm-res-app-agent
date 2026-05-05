targetScope = 'resourceGroup'

metadata name = 'Using only defaults'
metadata description = 'This instance deploys the module with the minimum set of required parameters.'

@description('Required. Initial sponsor group ID for the agent identity.')
param initialSponsorGroupId string

@description('Optional. Token used to make the resource name unique.')
param nameToken string = uniqueString(resourceGroup().id, deployment().name)

module testDeployment '../../../main.bicep' = {
  name: 'agent-defaults-${substring(nameToken, 0, 6)}'
  params: {
    name: take('aa${nameToken}', 32)
    agentIdentity: {
      initialSponsorGroupId: initialSponsorGroupId
    }
    enableTelemetry: false
  }
}
