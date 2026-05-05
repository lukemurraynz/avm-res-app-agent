targetScope = 'resourceGroup'

metadata name = 'Using all parameters'
metadata description = 'This instance deploys the module with all optional parameters exercised.'

@description('Required. Initial sponsor group ID for the agent identity.')
param initialSponsorGroupId string

@description('Required. Principal ID to assign Reader on the agent.')
param readerPrincipalId string

@description('Optional. Application Insights application ID.')
param applicationInsightsAppId string = ''

@secure()
@description('Optional. Application Insights connection string.')
param applicationInsightsConnectionString string = ''

@secure()
@description('Optional. Incident management connection key.')
param incidentConnectionKey string = ''

@description('Optional. Token used to make the resource name unique.')
param nameToken string = uniqueString(resourceGroup().id, deployment().name)

module testDeployment '../../../main.bicep' = {
  name: 'agent-max-${substring(nameToken, 0, 6)}'
  params: {
    name: take('am${nameToken}', 32)
    agentIdentity: {
      initialSponsorGroupId: initialSponsorGroupId
    }
    actionConfiguration: {
      accessLevel: 'Low'
      mode: 'Review'
    }
    agentSpaceId: 'space-${nameToken}'
    defaultModel: {
      name: 'gpt-5'
      provider: 'MicrosoftFoundry'
    }
    incidentManagementConfiguration: {
      connectionKey: incidentConnectionKey
      connectionName: 'Azure Monitor'
      connectionUrl: 'https://portal.azure.com'
      type: 'AzureMonitor'
    }
    knowledgeGraphConfiguration: {
      managedResources: [
        resourceGroup().id
      ]
    }
    logConfiguration: {
      applicationInsightsConfiguration: {
        appId: applicationInsightsAppId
        connectionString: applicationInsightsConnectionString
      }
    }
    managedIdentities: {
      systemAssigned: true
    }
    roleAssignments: [
      {
        principalId: readerPrincipalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    lock: {
      kind: 'CanNotDelete'
      name: 'agent-lock'
    }
    tags: {
      environment: 'test'
      scenario: 'max'
    }
    enableTelemetry: false
  }
}
