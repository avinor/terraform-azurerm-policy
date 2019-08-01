module "custom" {
    source = "avinor/policy/azurerm"
    version = "1.1.0"

    name = "restrict-location"
    description = "Restrict location that its allowed to create resources in."
    location = "westeurope"
    management_group_id = null

    custom_policy = {
        display_name = "Restrict location"
        mode = "All"

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