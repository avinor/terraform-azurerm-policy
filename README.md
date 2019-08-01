# Policy

Terraform module to create policies and apply them to different scopes. It can either create a new policy and assign, or use an existing policy definition.

If applying policies to management groups the scope should be set to `/providers/Microsoft.Management/managementGroups/group_id`.

## Required parameters

Although both `policy_definition_id` and `custom_policy` are optionally at least one of them have to be defined. If custom policy is defined it will overwrite `policy_definition_id`.

## Usage

All examples use [tau](https://github.com/avinor/tau) for deployment.

To use the build-in policy to restrict resource locations to specific regions:

```terraform
module {
    source = "avinor/policy/azurerm"
    version = "1.1.0"
}

inputs {
    name = "restrict-location"
    description = "Restrict location that its allowed to create resources in."
    location = "westeurope"

    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

    assignments = [
        {
            display_name = "Restrict resource location"
            scope = "/SCOPE"
            not_scopes = []
            parameters = <<PARAMETERS
                {
                    "listOfAllowedLocations": {
                        "value": [ "West Europe" ]
                    }
                }
            PARAMETERS
        },
    ]
}
```

If the build-in policies do not cover use case it is also possible to add a custom policy:

```terraform
module {
    source = "avinor/policy/azurerm"
    version = "1.1.0"
}

inputs {
    name = "restrict-location"
    description = "Restrict location that its allowed to create resources in."
    location = "westeurope"

    custom_policy = {
        display_name = "Restrict location"
        mode = "All"
        management_group_id = null

        metadata = <<METADATA
            {
            "category": "General"
            }
        METADATA

        policy_rule = <<POLICY_RULE
            {
            "if": {
            "not": {
                "field": "location",
                "in": "[parameters('allowedLocations')]"
            }
            },
            "then": {
            "effect": "audit"
            }
        }
        POLICY_RULE

        parameters = <<PARAMETERS
            {
            "allowedLocations": {
            "type": "Array",
            "metadata": {
                "description": "The list of allowed locations for resources.",
                "displayName": "Allowed locations",
                "strongType": "location"
            }
            }
        }
        PARAMETERS
    }

    assignments = [
        {
            display_name = "Restrict resource location"
            scope = "/SCOPE"
            not_scopes = []
            parameters = <<PARAMETERS
                {
                    "allowedLocations": {
                        "value": [ "West Europe" ]
                    }
                }
            PARAMETERS
        },
    ]
}
```
