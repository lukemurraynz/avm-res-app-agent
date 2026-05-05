# App Agent

This module deploys a `Microsoft.App/agents` resource by using API version `2026-01-01`.

The module follows the repository `bicep-avm-authoring` guidance for the AVM resource module interface:

- `name`, `location`, `tags`, and typed resource-specific configuration.
- Managed identity support through AVM common types.
- Role assignments, diagnostic settings, resource locks, telemetry, and required outputs.
- Exported user-defined types for complex parameters.

> This README is a checked-in starter. Regenerate it with the AVM Bicep documentation tooling before publishing the module.

## Minimum Example

```bicep
module agent 'br/public:avm/res/app/agent:0.1.0' = {
  name: 'agentDeployment'
  params: {
    name: 'sreagent01'
    agentIdentity: {
      initialSponsorGroupId: '<entra-group-object-id>'
    }
  }
}
```

## Notes

- The agent name must match the Azure schema pattern: start with a letter, end with a letter or number, and use only letters, numbers, and hyphens.
- The current Azure SRE Agent operational guidance expects a valid sponsor group ID, scoped permissions, and production rollout in Review mode before autonomous operation.
- Sensitive connection values are modeled as secure properties on the exported user-defined types.
