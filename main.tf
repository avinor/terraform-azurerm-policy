terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azurerm = "~> 1.44.0"
  }
}

locals {
  definition_id = var.custom_policy != null ? azurerm_policy_definition.policy.0.id : var.policy_definition_id
}

resource "azurerm_policy_definition" "policy" {
  count               = var.custom_policy != null ? 1 : 0
  name                = var.name
  policy_type         = "Custom"
  mode                = var.custom_policy.mode
  display_name        = var.custom_policy.display_name
  description         = var.description
  management_group_id = var.custom_policy.management_group_id

  metadata    = var.custom_policy.metadata
  policy_rule = var.custom_policy.policy_rule
  parameters  = var.custom_policy.parameters

  lifecycle {
    # Ignore metadata changes as Azure adds additional metadata module does not handle
    ignore_changes = [
      metadata,
    ]
  }
}

resource "azurerm_policy_assignment" "policy" {
  count                = length(var.assignments)
  name                 = "${var.name}-${count.index}"
  scope                = var.assignments[count.index].scope
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.assignments[count.index].display_name
  location             = var.location

  identity {
    type = var.create_identity ? "SystemAssigned" : "None"
  }

  not_scopes = var.assignments[count.index].not_scopes
  parameters = var.assignments[count.index].parameters
}