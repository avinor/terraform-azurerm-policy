module "existing" {
  source = "../../"

  name        = "restrict-location"
  description = "Restrict location that its allowed to create resources in."
  location    = "westeurope"

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  resource_group_assignments = [
    {
      display_name      = "Restrict resource location"
      resource_group_id = "/subscription/../resourceGroup/mygroup"
      not_scopes        = []
      parameters        = <<PARAMETERS
                {
                    "listOfAllowedLocations": {
                        "value": [ "West Europe" ]
                    }
                }
            PARAMETERS
    },
  ]
}
