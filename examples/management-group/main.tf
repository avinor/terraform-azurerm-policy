module "management-group" {
  source = "../../"

  name        = "restrict-location"
  description = "Restrict location that its allowed to create resources in."
  location    = "westeurope"

  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  assignments = [
    {
      display_name = "Restrict resource location"
      id           = "/providers/Microsoft.Management/managementGroups/root_mgm_grp"
      not_scopes   = []
      parameters   = <<PARAMETERS
        {
          "listOfAllowedLocations": {
            "value": [ "West Europe" ]
          }
        }
      PARAMETERS
      exemption    = null
    },
  ]
}
