targetScope = 'resourceGroup'

metadata name = 'WAF-aligned'
metadata description = 'This instance deploys the module with safer operational defaults for production-style validation.'

@description('Required. Initial sponsor group ID for the agent identity.')
param initialSponsorGroupId string

@description('Optional. Token used to make the resource name unique.')
param nameToken string = uniqueString(resourceGroup().id, deployment().name)

module testDeployment '../../../main.bicep' = {
  name: 'agent-waf-${substring(nameToken, 0, 6)}'
  params: {
    name: take('aw${nameToken}', 32)
    agentIdentity: {
      initialSponsorGroupId: initialSponsorGroupId
    }
    actionConfiguration: {
      accessLevel: 'Low'
      mode: 'Review'
    }
    defaultModel: {
      name: 'gpt-5'
      provider: 'MicrosoftFoundry'
    }
    knowledgeGraphConfiguration: {
      managedResources: [
        resourceGroup().id
      ]
    }
    managedIdentities: {
      systemAssigned: true
    }
    lock: {
      kind: 'CanNotDelete'
    }
    tags: {
      environment: 'waf'
      workload: 'sre'
    }
    enableTelemetry: false
  }
}
