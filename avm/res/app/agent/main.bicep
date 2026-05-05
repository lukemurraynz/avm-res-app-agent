metadata name = 'App Agent'
metadata description = 'This module deploys a Microsoft.App/agents resource.'

import {
  diagnosticSettingFullType
  lockType
  managedIdentityAllType
  roleAssignmentType
} from 'br/public:avm/utl/types/avm-common-types:0.6.1'

@description('Required. Name of the agent.')
@minLength(2)
@maxLength(32)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. Agent identity configuration for accessing resources.')
param agentIdentity agentIdentityType

@description('Optional. Configuration for actions the agent can perform.')
param actionConfiguration actionConfigurationType?

@description('Optional. The agent space ID referenced by the agent.')
param agentSpaceId string?

@description('Optional. Default AI model configuration for the agent.')
param defaultModel defaultModelType?

@description('Optional. Incident management configuration.')
param incidentManagementConfiguration incidentManagementConfigurationType?

@description('Optional. Knowledge graph configuration for the agent.')
param knowledgeGraphConfiguration knowledgeGraphConfigurationType?

@description('Optional. Log configuration for the agent.')
param logConfiguration logConfigurationType?

@allowed([
  'Preview'
  'Stable'
])
@description('Optional. The upgrade channel of the agent.')
param upgradeChannel string = 'Stable'

@description('Optional. Tags of the resource.')
param tags tagsType?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentityAllType?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType[]?

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingFullType[]?

@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Enable/disable usage telemetry for this module.')
param enableTelemetry bool = true

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), id => { '${id}': {} }),
  {},
  (current, next) => union(current, next)
)

var identity = !empty(managedIdentities) ? {
  type: (managedIdentities.?systemAssigned ?? false)
    ? (!empty(formattedUserAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
    : (!empty(formattedUserAssignedIdentities) ? 'UserAssigned' : 'None')
  userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
} : null

var formattedRoleAssignments = [
  for roleAssignment in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
      ? roleAssignment.roleDefinitionIdOrName
      : (contains(roleAssignment.roleDefinitionIdOrName, '-') ? subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName) : roleDefinitions(roleAssignment.roleDefinitionIdOrName).id)
  })
]

var properties = union(
  {
    agentIdentity: agentIdentity
    upgradeChannel: upgradeChannel
  },
  !empty(actionConfiguration) ? { actionConfiguration: actionConfiguration } : {},
  !empty(agentSpaceId) ? { agentSpaceId: agentSpaceId } : {},
  !empty(defaultModel) ? { defaultModel: defaultModel } : {},
  !empty(incidentManagementConfiguration) ? { incidentManagementConfiguration: incidentManagementConfiguration } : {},
  !empty(knowledgeGraphConfiguration) ? { knowledgeGraphConfiguration: knowledgeGraphConfiguration } : {},
  !empty(logConfiguration) ? { logConfiguration: logConfiguration } : {}
)

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '46d3xbcp.res.app-agent.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource agent 'Microsoft.App/agents@2026-01-01' = {
  name: name
  location: location
  identity: identity
  tags: tags
  properties: properties
}

resource agentLock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  scope: agent
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.')
  }
}

resource agentRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleAssignment in formattedRoleAssignments: {
    name: roleAssignment.?name ?? guid(agent.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    scope: agent
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
  }
]

#disable-next-line use-recent-api-versions
resource agentDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for diagnosticSetting in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    scope: agent
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? [
          {
            categoryGroup: 'allLogs'
          }
        ]): {
          category: group.?category
          categoryGroup: group.?categoryGroup
          enabled: group.?enabled ?? true
        }
      ]
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [
          {
            category: 'AllMetrics'
          }
        ]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
  }
]

@description('The resource ID of the deployed resource.')
output resourceId string = agent.id

@description('The name of the deployed resource.')
output name string = agent.name

@description('The resource group the resource was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = agent.location

@description('The principal ID of the system-assigned managed identity.')
output systemAssignedMIPrincipalId string? = agent.?identity.?principalId

@export()
@description('Agent action execution configuration.')
type actionConfigurationType = {
  @description('Optional. The access level of the action.')
  accessLevel: ('High' | 'Low')?

  @description('Optional. The identity used by the action.')
  identity: string?

  @description('Optional. The execution mode of the action.')
  mode: ('Autonomous' | 'ReadOnly' | 'Review')?
}

@export()
@description('Agent identity configuration for accessing resources.')
type agentIdentityType = {
  @description('Required. Initial sponsor group ID.')
  initialSponsorGroupId: string
}

@export()
@description('Application Insights configuration for agent logs.')
type applicationInsightsConfigurationType = {
  @description('Optional. The Application ID for the Application Insights resource.')
  appId: string?

  @secure()
  @description('Optional. The connection string for the Application Insights resource.')
  connectionString: string?
}

@export()
@description('Default AI model configuration for the agent.')
type defaultModelType = {
  @description('Optional. Model name, for example gpt-5, claude-opus-4-5, or claude-sonnet-4-5.')
  name: string?

  @description('Optional. AI provider name, for example MicrosoftFoundry or Anthropic.')
  provider: string?
}

@export()
@description('Incident management system connection configuration.')
type incidentManagementConfigurationType = {
  @secure()
  @description('Optional. The key for the connection.')
  connectionKey: string?

  @description('Optional. The name of the connection.')
  connectionName: string?

  @description('Optional. The URL of the connection.')
  connectionUrl: string?

  @description('Optional. The user for the connection.')
  oboUser: string?

  @description('Optional. The type of incident management system.')
  type: string?
}

@export()
@description('Knowledge graph configuration for the agent.')
type knowledgeGraphConfigurationType = {
  @description('Optional. The identity used to access the knowledge graph.')
  identity: string?

  @description('Optional. The list of resources managed by the agent.')
  managedResources: string[]?
}

@export()
@description('Log configuration for the agent.')
type logConfigurationType = {
  @description('Optional. Application Insights configuration.')
  applicationInsightsConfiguration: applicationInsightsConfigurationType?
}

@export()
@description('Tags to apply to the resource.')
type tagsType = {
  @description('Optional. A tag name and value pair.')
  *: string
}
