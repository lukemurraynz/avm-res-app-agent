# App Agent `[Microsoft.App/agents]`

This module deploys an Azure SRE Agent resource using `Microsoft.App/agents`.

It provides an AVM-style resource module interface for the agent itself, optional connector child resources, role assignments, diagnostic settings, resource locks, telemetry, and required outputs. The module is intentionally focused on the generic Azure SRE Agent resource surface. Workload-specific alert rules, response plans, runbooks, scheduled tasks, custom skills, sub-agents, and tenant-specific data-plane configuration should remain in the consuming workload or pattern module.

You can reference the module as follows:

```bicep
module agent 'br/public:avm/res/app/agent:<version>' = {
  name: 'agentDeployment'
  params: { (...) }
}
```

For examples, please refer to the [Usage examples](#usage-examples) section.

> **Publishing note**: This repository is an AVM-style module candidate. Before publishing to the public Bicep registry, regenerate this README using the AVM documentation tooling so that the generated documentation matches the compiled `main.json` exactly.

## Navigation

- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Operational guidance](#operational-guidance)
- [Data Collection](#data-collection)

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.App/agents` | `2025-05-01-preview` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.app_agents.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.App/agents) |
| `Microsoft.App/agents/connectors` | `2025-05-01-preview` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.app_agents_connectors.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.App/agents/connectors) |
| `Microsoft.Authorization/locks` | `2020-05-01` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.Authorization/2020-05-01/locks) |
| `Microsoft.Authorization/roleAssignments` | `2022-04-01` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.Insights/diagnosticSettings` | `2021-05-01-preview` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |
| `Microsoft.Resources/deployments` | `2024-03-01` | [AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.resources_deployments.html)<br>[Template reference](https://learn.microsoft.com/azure/templates/Microsoft.Resources/2024-03-01/deployments) |

## Usage examples

The following section provides usage examples for the module, aligned to the deployment test folders in this repository.

> **Note**: Each example lists all required parameters first, followed by the rest in alphabetical order.

> **Note**: To reference the module, use the syntax `br/public:avm/res/app/agent:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [WAF-aligned](#example-2-waf-aligned)
- [Using all parameters](#example-3-using-all-parameters)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum required parameters. It expects an existing user-assigned managed identity resource ID to be supplied by the consuming deployment.

You can find the full example and the setup of its dependencies in the deployment test folder path [`/tests/e2e/defaults`](./tests/e2e/defaults).

via Bicep module

```bicep
module agent 'br/public:avm/res/app/agent:<version>' = {
  name: 'agentDeployment'
  params: {
    // Required parameters
    name: 'aadefaults001'
    managedIdentities: {
      userAssignedResourceIds: [
        '<userAssignedManagedIdentityResourceId>'
      ]
    }
  }
}
```

via JSON parameters file

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "value": "aadefaults001"
    },
    "managedIdentities": {
      "value": {
        "userAssignedResourceIds": [
          "<userAssignedManagedIdentityResourceId>"
        ]
      }
    }
  }
}
```

via Bicep parameters file

```bicep-params
using 'br/public:avm/res/app/agent:<version>'

// Required parameters
param name = 'aadefaults001'
param managedIdentities = {
  userAssignedResourceIds: [
    '<userAssignedManagedIdentityResourceId>'
  ]
}
```

### Example 2: _WAF-aligned_

This instance deploys the module with safer operational defaults for production-style validation: review mode, a low action access level, a knowledge graph scope, a user-assigned managed identity, a delete lock, and workload tags.

You can find the full example and the setup of its dependencies in the deployment test folder path [`/tests/e2e/waf-aligned`](./tests/e2e/waf-aligned).

via Bicep module

```bicep
module agent 'br/public:avm/res/app/agent:<version>' = {
  name: 'agentDeployment'
  params: {
    // Required parameters
    name: 'aawaf001'
    managedIdentities: {
      userAssignedResourceIds: [
        '<userAssignedManagedIdentityResourceId>'
      ]
    }
    // Non-required parameters
    actionConfiguration: {
      accessLevel: 'Low'
      identity: '<userAssignedManagedIdentityResourceId>'
      mode: 'Review'
    }
    defaultModel: {
      name: 'gpt-5'
      provider: 'MicrosoftFoundry'
    }
    knowledgeGraphConfiguration: {
      identity: '<userAssignedManagedIdentityResourceId>'
      managedResources: [
        '<managedResourceId>'
      ]
    }
    lock: {
      kind: 'CanNotDelete'
    }
    tags: {
      environment: 'prod'
      workload: 'sre'
    }
  }
}
```

via JSON parameters file

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "value": "aawaf001"
    },
    "managedIdentities": {
      "value": {
        "userAssignedResourceIds": [
          "<userAssignedManagedIdentityResourceId>"
        ]
      }
    },
    "actionConfiguration": {
      "value": {
        "accessLevel": "Low",
        "identity": "<userAssignedManagedIdentityResourceId>",
        "mode": "Review"
      }
    },
    "defaultModel": {
      "value": {
        "name": "gpt-5",
        "provider": "MicrosoftFoundry"
      }
    },
    "knowledgeGraphConfiguration": {
      "value": {
        "identity": "<userAssignedManagedIdentityResourceId>",
        "managedResources": [
          "<managedResourceId>"
        ]
      }
    },
    "lock": {
      "value": {
        "kind": "CanNotDelete"
      }
    },
    "tags": {
      "value": {
        "environment": "prod",
        "workload": "sre"
      }
    }
  }
}
```

via Bicep parameters file

```bicep-params
using 'br/public:avm/res/app/agent:<version>'

// Required parameters
param name = 'aawaf001'
param managedIdentities = {
  userAssignedResourceIds: [
    '<userAssignedManagedIdentityResourceId>'
  ]
}

// Non-required parameters
param actionConfiguration = {
  accessLevel: 'Low'
  identity: '<userAssignedManagedIdentityResourceId>'
  mode: 'Review'
}
param defaultModel = {
  name: 'gpt-5'
  provider: 'MicrosoftFoundry'
}
param knowledgeGraphConfiguration = {
  identity: '<userAssignedManagedIdentityResourceId>'
  managedResources: [
    '<managedResourceId>'
  ]
}
param lock = {
  kind: 'CanNotDelete'
}
param tags = {
  environment: 'prod'
  workload: 'sre'
}
```

### Example 3: _Using all parameters_

This instance deploys the module with most of its supported features enabled, including action configuration, model selection, incident management configuration, knowledge graph configuration, Application Insights logging, role assignments, locks, tags, and managed identity.

You can find the full example and the setup of its dependencies in the deployment test folder path [`/tests/e2e/max`](./tests/e2e/max).

via Bicep module

```bicep
module agent 'br/public:avm/res/app/agent:<version>' = {
  name: 'agentDeployment'
  params: {
    // Required parameters
    name: 'aamax001'
    managedIdentities: {
      userAssignedResourceIds: [
        '<userAssignedManagedIdentityResourceId>'
      ]
    }
    // Non-required parameters
    actionConfiguration: {
      accessLevel: 'Low'
      identity: '<userAssignedManagedIdentityResourceId>'
      mode: 'Review'
    }
    agentSpaceId: '<agentSpaceId>'
    defaultModel: {
      name: 'gpt-5'
      provider: 'MicrosoftFoundry'
    }
    diagnosticSettings: [
      {
        name: 'agent-diagnostics'
        workspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
      }
    ]
    incidentManagementConfiguration: {
      connectionKey: '<secureIncidentConnectionKey>'
      connectionName: 'Azure Monitor'
      connectionUrl: 'https://portal.azure.com'
      type: 'AzureMonitor'
    }
    knowledgeGraphConfiguration: {
      identity: '<userAssignedManagedIdentityResourceId>'
      managedResources: [
        '<managedResourceId>'
      ]
    }
    lock: {
      kind: 'CanNotDelete'
      name: 'agent-lock'
    }
    logConfiguration: {
      applicationInsightsConfiguration: {
        appId: '<applicationInsightsAppId>'
        applicationInsightsResourceId: '<applicationInsightsResourceId>'
        connectionString: '<secureApplicationInsightsConnectionString>'
      }
    }
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    tags: {
      environment: 'test'
      scenario: 'max'
    }
  }
}
```

via JSON parameters file

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "value": "aamax001"
    },
    "managedIdentities": {
      "value": {
        "userAssignedResourceIds": [
          "<userAssignedManagedIdentityResourceId>"
        ]
      }
    },
    "actionConfiguration": {
      "value": {
        "accessLevel": "Low",
        "identity": "<userAssignedManagedIdentityResourceId>",
        "mode": "Review"
      }
    },
    "agentSpaceId": {
      "value": "<agentSpaceId>"
    },
    "defaultModel": {
      "value": {
        "name": "gpt-5",
        "provider": "MicrosoftFoundry"
      }
    },
    "diagnosticSettings": {
      "value": [
        {
          "name": "agent-diagnostics",
          "workspaceResourceId": "<logAnalyticsWorkspaceResourceId>"
        }
      ]
    },
    "incidentManagementConfiguration": {
      "value": {
        "connectionKey": "<secureIncidentConnectionKey>",
        "connectionName": "Azure Monitor",
        "connectionUrl": "https://portal.azure.com",
        "type": "AzureMonitor"
      }
    },
    "knowledgeGraphConfiguration": {
      "value": {
        "identity": "<userAssignedManagedIdentityResourceId>",
        "managedResources": [
          "<managedResourceId>"
        ]
      }
    },
    "lock": {
      "value": {
        "kind": "CanNotDelete",
        "name": "agent-lock"
      }
    },
    "logConfiguration": {
      "value": {
        "applicationInsightsConfiguration": {
          "appId": "<applicationInsightsAppId>",
          "applicationInsightsResourceId": "<applicationInsightsResourceId>",
          "connectionString": "<secureApplicationInsightsConnectionString>"
        }
      }
    },
    "roleAssignments": {
      "value": [
        {
          "principalId": "<principalId>",
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Reader"
        }
      ]
    },
    "tags": {
      "value": {
        "environment": "test",
        "scenario": "max"
      }
    }
  }
}
```

via Bicep parameters file

```bicep-params
using 'br/public:avm/res/app/agent:<version>'

// Required parameters
param name = 'aamax001'
param managedIdentities = {
  userAssignedResourceIds: [
    '<userAssignedManagedIdentityResourceId>'
  ]
}

// Non-required parameters
param actionConfiguration = {
  accessLevel: 'Low'
  identity: '<userAssignedManagedIdentityResourceId>'
  mode: 'Review'
}
param agentSpaceId = '<agentSpaceId>'
param defaultModel = {
  name: 'gpt-5'
  provider: 'MicrosoftFoundry'
}
param diagnosticSettings = [
  {
    name: 'agent-diagnostics'
    workspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
  }
]
param incidentManagementConfiguration = {
  connectionKey: '<secureIncidentConnectionKey>'
  connectionName: 'Azure Monitor'
  connectionUrl: 'https://portal.azure.com'
  type: 'AzureMonitor'
}
param knowledgeGraphConfiguration = {
  identity: '<userAssignedManagedIdentityResourceId>'
  managedResources: [
    '<managedResourceId>'
  ]
}
param lock = {
  kind: 'CanNotDelete'
  name: 'agent-lock'
}
param logConfiguration = {
  applicationInsightsConfiguration: {
    appId: '<applicationInsightsAppId>'
    applicationInsightsResourceId: '<applicationInsightsResourceId>'
    connectionString: '<secureApplicationInsightsConnectionString>'
  }
}
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Reader'
  }
]
param tags = {
  environment: 'test'
  scenario: 'max'
}
```

## Parameters

### Required parameters

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`managedIdentities`](#parameter-managedidentities) | `managedIdentityUserAssignedType` | User-assigned managed identities for this resource. Azure SRE Agent requires a user-assigned managed identity for resource operations and also creates an internal system-assigned identity. |
| [`name`](#parameter-name) | `string` | Name of the agent. |

### Optional parameters

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actionAccessLevel`](#parameter-actionaccesslevel) | `string` | First-class action access level. Ignored when `actionConfiguration` is supplied. |
| [`actionConfiguration`](#parameter-actionconfiguration) | `actionConfigurationType` | Configuration for actions the agent can perform. |
| [`actionIdentity`](#parameter-actionidentity) | `string` | First-class managed identity resource ID used by actions. Ignored when `actionConfiguration` is supplied. |
| [`actionMode`](#parameter-actionmode) | `string` | First-class action execution mode. Ignored when `actionConfiguration` is supplied. |
| [`agentIdentity`](#parameter-agentidentity) | `agentIdentityType` | Legacy agent identity configuration. Not used by the current Microsoft.App/agents preview API. |
| [`agentSpaceId`](#parameter-agentspaceid) | `string` | The agent space ID referenced by the agent. |
| [`connectors`](#parameter-connectors) | `connectorType[]` | Connector child resources to deploy under the agent. Use for ARM-supported connectors such as AppInsights, LogAnalytics, MonitorClient, and MCP endpoints. |
| [`defaultModel`](#parameter-defaultmodel) | `defaultModelType` | Default AI model configuration for the agent. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | `diagnosticSettingFullType[]` | Diagnostic settings of the service. |
| [`enableTelemetry`](#parameter-enabletelemetry) | `bool` | Enable or disable usage telemetry for this module. |
| [`experimentalSettings`](#parameter-experimentalsettings) | `object` | Experimental feature flags for the agent. |
| [`incidentManagementConfiguration`](#parameter-incidentmanagementconfiguration) | `incidentManagementConfigurationType` | Incident management configuration. |
| [`knowledgeGraphConfiguration`](#parameter-knowledgegraphconfiguration) | `knowledgeGraphConfigurationType` | Knowledge graph configuration for the agent. |
| [`location`](#parameter-location) | `string` | Location for all resources. |
| [`lock`](#parameter-lock) | `lockType` | Lock settings of the service. |
| [`logConfiguration`](#parameter-logconfiguration) | `logConfigurationType` | Log configuration for the agent. |
| [`mcpServers`](#parameter-mcpservers) | `array` | MCP server configuration for the agent. |
| [`roleAssignments`](#parameter-roleassignments) | `roleAssignmentType[]` | Array of role assignments to create. |
| [`tags`](#parameter-tags) | `tagsType` | Tags of the resource. |
| [`upgradeChannel`](#parameter-upgradechannel) | `string` | Upgrade channel of the agent. |

### Parameter: `managedIdentities`

User-assigned managed identities for this resource. Azure SRE Agent requires a user-assigned managed identity for resource operations and also creates an internal system-assigned identity.

- Required: Yes
- Type: `managedIdentityUserAssignedType`

```bicep
managedIdentities: {
  userAssignedResourceIds: [
    '<userAssignedManagedIdentityResourceId>'
  ]
}
```

### Parameter: `name`

Name of the agent.

- Required: Yes
- Type: `string`
- Minimum length: `2`
- Maximum length: `32`
- Pattern from the resource provider: `^[A-Za-z]([-A-Za-z0-9]{0,30}[A-Za-z0-9])$`

```bicep
name: 'aawaf001'
```

### Parameter: `actionAccessLevel`

First-class action access level. Ignored when `actionConfiguration` is supplied.

- Required: No
- Type: `string`
- Allowed values: `High`, `Low`

```bicep
actionAccessLevel: 'Low'
```

### Parameter: `actionConfiguration`

Configuration for actions the agent can perform. If supplied, this object takes precedence over `actionAccessLevel`, `actionIdentity`, and `actionMode`.

- Required: No
- Type: `actionConfigurationType`

```bicep
actionConfiguration: {
  accessLevel: 'Low'
  identity: '<userAssignedManagedIdentityResourceId>'
  mode: 'Review'
}
```

### Parameter: `actionIdentity`

First-class managed identity resource ID used by actions. Ignored when `actionConfiguration` is supplied.

- Required: No
- Type: `string`

```bicep
actionIdentity: '<userAssignedManagedIdentityResourceId>'
```

### Parameter: `actionMode`

First-class action execution mode. Ignored when `actionConfiguration` is supplied.

- Required: No
- Type: `string`
- Allowed values: `Autonomous`, `ReadOnly`, `Review`, `autonomous`, `readOnly`, `review`

```bicep
actionMode: 'Review'
```

### Parameter: `agentIdentity`

Legacy agent identity configuration. Not used by the current Microsoft.App/agents preview API.

- Required: No
- Type: `agentIdentityType`

```bicep
agentIdentity: {
  initialSponsorGroupId: '<initialSponsorGroupId>'
}
```

### Parameter: `agentSpaceId`

The agent space ID referenced by the agent.

- Required: No
- Type: `string`

```bicep
agentSpaceId: '<agentSpaceId>'
```

### Parameter: `connectors`

Connector child resources to deploy under the agent. Use for ARM-supported connectors such as AppInsights, LogAnalytics, MonitorClient, and MCP endpoints.

- Required: No
- Type: `connectorType[]`

```bicep
connectors: [
  {
    name: 'azure-monitor'
    dataConnectorType: 'MonitorClient'
    dataSource: 'n/a'
    identity: 'system'
  }
  {
    name: 'microsoft-learn'
    dataConnectorType: 'Mcp'
    dataSource: 'microsoft-learn-mcp'
    extendedProperties: {
      type: 'http'
      endpoint: 'https://learn.microsoft.com/api/mcp'
      authType: 'CustomHeaders'
      toolsVisibleToMetaAgent: [
        'microsoft-learn_microsoft_docs_search'
        'microsoft-learn_microsoft_docs_fetch'
      ]
    }
    identity: ''
  }
]
```

### Parameter: `defaultModel`

Default AI model configuration for the agent.

- Required: No
- Type: `defaultModelType`

```bicep
defaultModel: {
  name: 'gpt-5'
  provider: 'MicrosoftFoundry'
}
```

### Parameter: `diagnosticSettings`

Diagnostic settings of the service.

- Required: No
- Type: `diagnosticSettingFullType[]`

```bicep
diagnosticSettings: [
  {
    name: 'agent-diagnostics'
    workspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
  }
]
```

### Parameter: `enableTelemetry`

Enable or disable usage telemetry for this module.

- Required: No
- Type: `bool`
- Default: `true`

```bicep
enableTelemetry: false
```

### Parameter: `experimentalSettings`

Experimental feature flags for the agent.

- Required: No
- Type: `object`

```bicep
experimentalSettings: {}
```

### Parameter: `incidentManagementConfiguration`

Incident management configuration.

- Required: No
- Type: `incidentManagementConfigurationType`

```bicep
incidentManagementConfiguration: {
  connectionKey: '<secureIncidentConnectionKey>'
  connectionName: 'Azure Monitor'
  connectionUrl: 'https://portal.azure.com'
  type: 'AzureMonitor'
}
```

### Parameter: `knowledgeGraphConfiguration`

Knowledge graph configuration for the agent.

- Required: No
- Type: `knowledgeGraphConfigurationType`

```bicep
knowledgeGraphConfiguration: {
  identity: '<userAssignedManagedIdentityResourceId>'
  managedResources: [
    '<managedResourceId>'
  ]
}
```

### Parameter: `location`

Location for all resources.

- Required: No
- Type: `string`
- Default: `[resourceGroup().location]`

```bicep
location: '<location>'
```

### Parameter: `lock`

Lock settings of the service.

- Required: No
- Type: `lockType`

```bicep
lock: {
  kind: 'CanNotDelete'
}
```

### Parameter: `logConfiguration`

Log configuration for the agent.

- Required: No
- Type: `logConfigurationType`

```bicep
logConfiguration: {
  applicationInsightsConfiguration: {
    appId: '<applicationInsightsAppId>'
    applicationInsightsResourceId: '<applicationInsightsResourceId>'
    connectionString: '<secureApplicationInsightsConnectionString>'
  }
}
```

### Parameter: `mcpServers`

MCP server configuration for the agent.

- Required: No
- Type: `array`

```bicep
mcpServers: []
```

### Parameter: `roleAssignments`

Array of role assignments to create on the deployed agent resource.

- Required: No
- Type: `roleAssignmentType[]`

```bicep
roleAssignments: [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Reader'
  }
]
```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: `tagsType`

```bicep
tags: {
  environment: 'prod'
  workload: 'sre'
}
```

### Parameter: `upgradeChannel`

Upgrade channel of the agent.

- Required: No
- Type: `string`
- Default: `Stable`
- Allowed values: `Preview`, `Stable`

```bicep
upgradeChannel: 'Stable'
```

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `agentEndpoint` | `string` | The Azure SRE Agent endpoint. |
| `connectorResourceIds` | `string[]` | Resource IDs of the deployed connector child resources. |
| `location` | `string` | Location the resource was deployed into. |
| `name` | `string` | Name of the deployed resource. |
| `resourceGroupName` | `string` | Resource group the resource was deployed into. |
| `resourceId` | `string` | Resource ID of the deployed resource. |
| `systemAssignedMIPrincipalId` | `string` | Principal ID of the system-assigned managed identity attached to the agent. |
| `userAssignedMIResourceIds` | `string[]` | Resource IDs of the user-assigned managed identities attached to the agent. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files and all remote-referenced files used by this module.

| Reference | Type |
| :-- | :-- |
| `br/public:avm/utl/types/avm-common-types:0.6.1` | Remote reference |

## Operational guidance

- Use a user-assigned managed identity for agent actions and knowledge graph access so permissions are explicit, reviewable, and reusable across deployments.
- Start production rollouts with `actionConfiguration.mode` set to `Review` and `accessLevel` set to `Low`. Move toward higher autonomy only after deterministic controls, monitoring, and approval paths are proven.
- Scope `knowledgeGraphConfiguration.managedResources` to the smallest resource group, subscription, or resource IDs the agent needs to observe and operate.
- Keep workload-specific Azure Monitor alert rules, action groups, automation runbooks, response plans, scheduled tasks, custom skills, and sub-agents outside this generic resource module.
- Prefer diagnostic settings to a central Log Analytics workspace when the resource provider emits logs and metrics for your chosen region and API version.
- Treat connector `dataSource`, `extendedProperties`, incident connection keys, and Application Insights connection strings as sensitive. Prefer Key Vault or secure pipeline variables for values that are secrets or credentials.
- For MCP connectors, explicitly document which tools should be visible to the meta-agent and validate tool visibility after deployment. Connector health alone does not prove that the agent can call the intended tools.

More detailed guidance is available in [`docs/operational-guidance.md`](./docs/operational-guidance.md).

## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services.

You may turn off telemetry by setting `enableTelemetry` to `false`. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft's privacy statement.

You can learn more about data collection and use in the help documentation and Microsoft's privacy statement. Your use of the software operates as your consent to these practices.
