module "existing" {
    source = "avinor/policy/azurerm"
    version = "1.1.0"

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