# AVM Resource Module: App Agent

This repository contains an AVM-style Bicep resource module candidate for Azure SRE Agent:

```text
avm/res/app/agent
```

The module deploys `Microsoft.App/agents` with support for user-assigned managed identity, optional agent connectors, role assignments, diagnostic settings, locks, telemetry, and AVM-style outputs.

## Module documentation

- [Module README](./avm/res/app/agent/README.md)
- [Changelog](./avm/res/app/agent/CHANGELOG.md)

## Module status

This is an unofficial AVM-style module candidate. Before publishing as an official Azure Verified Module, regenerate the README with the AVM documentation tooling, recompile `main.json` from `main.bicep`, and validate the e2e deployment scenarios.

## Quick reference

```bicep
module agent 'br/public:avm/res/app/agent:<version>' = {
  name: 'agentDeployment'
  params: {
    name: 'aawaf001'
    managedIdentities: {
      userAssignedResourceIds: [
        '<userAssignedManagedIdentityResourceId>'
      ]
    }
    actionConfiguration: {
      accessLevel: 'Low'
      identity: '<userAssignedManagedIdentityResourceId>'
      mode: 'Review'
    }
    knowledgeGraphConfiguration: {
      identity: '<userAssignedManagedIdentityResourceId>'
      managedResources: [
        '<managedResourceId>'
      ]
    }
  }
}
```
