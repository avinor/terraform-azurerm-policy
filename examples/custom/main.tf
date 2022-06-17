module "custom" {
  source = "../../"

  name        = "restrict-location"
  description = "Restrict location that its allowed to create resources in."
  location    = "westeurope"

  custom_policy = {
    display_name = "Restrict location"
    mode         = "All"

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
    exemption    = null
  }

  assignments = [
    {
      display_name = "Restrict resource location"
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000"
      not_scopes   = []
      parameters   = <<PARAMETERS
        {
          "allowedLocations": {
            "value": [ "West Europe" ]
          }
        }
      PARAMETERS
      exemption    = null
    },
  ]
}
