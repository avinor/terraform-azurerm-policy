terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = ">= 1.29.0"
  }
}

locals {
  definition_id = var.custom_policy != null ? azurerm_policy_definition.policy.0.id : var.policy_definition_id
}

resource "azurerm_policy_definition" "policy" {
  count        = var.custom_policy != null ? 1 : 0
  name         = var.name
  policy_type  = "Custom"
  mode         = var.custom_policy.mode
  display_name = var.custom_policy.display_name
  description  = var.description

  metadata    = var.custom_policy.metadata
  policy_rule = var.custom_policy.policy_rule
  parameters  = var.custom_policy.parameters
}

resource "azurerm_policy_assignment" "policy" {
  count                = length(var.assignments)
  name                 = "${var.name}-${count.index}"
  scope                = var.assignments[count.index].scope
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.assignments[count.index].display_name

  not_scopes = var.assignments[count.index].not_scopes
  parameters = var.assignments[count.index].parameters
}