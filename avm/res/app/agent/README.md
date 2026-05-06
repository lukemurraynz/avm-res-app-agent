# App Agent

This module deploys a `Microsoft.App/agents` resource by using API version `2025-05-01-preview`.

The module follows the repository `bicep-avm-authoring` guidance for the AVM resource module interface:

- `name`, `location`, `tags`, and typed resource-specific configuration.
- User-assigned managed identity support for SRE Agent resource operations.
- Role assignments, diagnostic settings, resource locks, telemetry, and required outputs.
- Exported user-defined types for complex parameters.

> This README is a checked-in starter. Regenerate it with the AVM Bicep documentation tooling before publishing the module.

## Minimum Example

```bicep
resource agentIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-sreagent01'
  location: resourceGroup().location
}

module agent 'br/public:avm/res/app/agent:0.1.0' = {
  name: 'agentDeployment'
  params: {
    name: 'sreagent01'
    actionConfiguration: {
      accessLevel: 'Low'
      identity: agentIdentity.id
      mode: 'review'
    }
    knowledgeGraphConfiguration: {
      identity: agentIdentity.id
      managedResources: [
        resourceGroup().id
      ]
    }
    managedIdentities: {
      userAssignedResourceIds: [
        agentIdentity.id
      ]
    }
  }
}
```

## Notes

- The agent name must match the Azure schema pattern: start with a letter, end with a letter or number, and use only letters, numbers, and hyphens.
- The agent resource uses both `SystemAssigned` and `UserAssigned` identity. The system-assigned identity is internal; set `actionConfiguration.identity` and `knowledgeGraphConfiguration.identity` to the user-assigned managed identity resource ID.
- Assign `SRE Agent Administrator` on the agent resource to the deploying operator or owning group.
- Use scoped permissions and production rollout in Review mode before autonomous operation.
- Sensitive connection values are modeled as secure properties on the exported user-defined types.
