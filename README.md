# Policy

Terraform module to create policies and apply them to different scopes. It can either create a new policy and assign, or use an existing policy definition.

If applying policies to management groups the id should be set to `/providers/Microsoft.Management/managementGroups/group_id`.

Assignments id is mapped to azurerm provider resources as follows:

| id                                                                             | azurerm resource                           |
|--------------------------------------------------------------------------------|--------------------------------------------|
| /providers/Microsoft.Management/managementGroups/...                           | azurerm_management_group_policy_assignment |
| /subscriptions/00000000-0000-0000-0000-000000000000                            | azurerm_subscription_policy_assignment     |
| /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup     | azurerm_resource_group_policy_assignment   |
| /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mygroup/... | azurerm_resource_policy_assignment         |

Assigments to different resource types is supported.

## Required parameters

Although both `policy_definition_id` and `custom_policy` are optionally at least one of them have to be defined. If custom policy is defined it will overwrite `policy_definition_id`.

## Usage

To use the build-in policy to restrict resource locations to specific regions:

```terraform
module "restrict-location" {
    source = "avinor/policy/azurerm"
    version = "1.1.0"

    name        = "restrict-location"
    description = "Restrict location that its allowed to create resources in."
    location    = "westeurope"

    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

    assignments = [
        {
            display_name = "Restrict resource location"
            id           = "/providers/Microsoft.Management/managementGroups/group_id"
            not_scopes   = []
            parameters   = <<PARAMETERS
                {
                    "listOfAllowedLocations": {
                        "value": [ "West Europe" ]
                    }
                }
            PARAMETERS
            exemption    = {
               name                            = "exemption-1"
               display_name                    = "Exemptio One"
               exemption_category              = "Waiver"
               policy_definition_reference_ids = ["identityEnableMFAForWritePermissionsMonitoring"]
          }
        },
    ]
}
```

If the build-in policies do not cover use case it is also possible to add a custom policy:

```terraform
module "restrict-location" {
    source = "avinor/policy/azurerm"
    version = "2.0.0"

    name = "restrict-location"
    description = "Restrict location that its allowed to create resources in."
    location = "westeurope"

    custom_policy = {
        display_name        = "Restrict location"
        mode                = "All"
        management_group_id = ""

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
        exemption = null
    }

    assignments = [
        {
            display_name = "Restrict resource location"
            id           = "/providers/Microsoft.Management/managementGroups/group_id"
            not_scopes   = []
            parameters   = <<PARAMETERS
                {
                    "allowedLocations": {
                        "value": [ "West Europe" ]
                    }
                }
            PARAMETERS
            exemption = null
        },
    ]
}
```
