module "policy-set-definitions" {
  source = "../../"

  name        = "enable-monitoring-asc"
  description = "Enable Monitoring in Azure Security Center policy assignment, based on the Azure Security Benchmark initiative which represents the policies and controls implementing security recommendations defined in Azure Security Benchmark v2, see https://aka.ms/azsecbm. This also serves as the Azure Security Center default policy initiative."
  location    = "westeurope"

  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"

  assignments = [
    {
      display_name = "[Preview]: Enable Monitoring in Azure Security Center"
      id           = "/providers/Microsoft.Management/managementGroups/root_mgm_grp"
      not_scopes   = []
      parameters   = <<PARAMETERS
                {
                    "allowedContainerImagesInKubernetesClusterRegex": {
                        "value": "^avinorregistry+\\.azurecr\\.io\\/.+$"
                    }
                }
            PARAMETERS
      exemption = {
        name                            = "extemption-1"
        exemption_category              = "Waiver"
        policy_definition_reference_ids = ["identityEnableMFAForWritePermissionsMonitoring"]
      }
    }
  ]
}
