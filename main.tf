terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }
  }
}
provider "azurerm" {
  features {}
}

locals {
  definition_id = var.custom_policy != null ? azurerm_policy_definition.policy.0.id : var.policy_definition_id

  management_group_assignments = [for a in var.assignments : a if length(regexall("^(?i)/providers/Microsoft.Management/managementGroups/", a.id)) == 1]
  resource_assignments         = [for a in var.assignments : a if length(regexall("^(?i)/subscriptions/[0-9a-f-]+/resourceGroups/\\w+/", a.id)) == 1]
  resource_group_assignments   = [for a in var.assignments : a if length(regexall("^(?i)/subscriptions/[0-9a-f-]+/resourceGroups/[^/]+$", a.id)) == 1]
  subscription_assignments     = [for a in var.assignments : a if length(regexall("^(?i)/subscriptions/[^/]+$", a.id)) == 1]
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

resource "azurerm_management_group_policy_assignment" "policy" {
  count                = length(local.management_group_assignments)
  name                 = "${var.name}-${count.index}"
  management_group_id  = local.management_group_assignments[count.index].id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = local.management_group_assignments[count.index].display_name
  location             = var.location

  dynamic "identity" {
    for_each = var.create_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  not_scopes = local.management_group_assignments[count.index].not_scopes
  parameters = local.management_group_assignments[count.index].parameters
}

resource "azurerm_management_group_policy_exemption" "policy" {
  for_each                        = local.management_group_assignments.exemption != null
  name                            = local.management_group_assignments[each.value].exemption.name
  management_group_id             = local.management_group_assignments[each.value].id
  policy_assignment_id            = azurerm_management_group_policy_assignment.policy[each.value].id
  exemption_category              = local.management_group_assignments[each.value].exemption.exemption_category
  policy_definition_reference_ids = local.management_group_assignments[each.value].exemption.policy_definition_reference_ids
}

resource "azurerm_resource_group_policy_assignment" "policy" {
  count                = length(local.resource_group_assignments)
  name                 = "${var.name}-${count.index}"
  resource_group_id    = local.resource_group_assignments[count.index].id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = local.resource_group_assignments[count.index].display_name
  location             = var.location

  dynamic "identity" {
    for_each = var.create_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  not_scopes = local.resource_group_assignments[count.index].not_scopes
  parameters = local.resource_group_assignments[count.index].parameters
}
#
resource "azurerm_resource_policy_assignment" "policy" {
  count                = length(local.resource_assignments)
  name                 = "${var.name}-${count.index}"
  resource_id          = local.resource_assignments[count.index].id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = local.resource_assignments[count.index].display_name
  location             = var.location

  dynamic "identity" {
    for_each = var.create_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  not_scopes = local.resource_assignments[count.index].not_scopes
  parameters = local.resource_assignments[count.index].parameters
}

resource "azurerm_subscription_policy_assignment" "policy" {
  count                = length(local.subscription_assignments)
  name                 = "${var.name}-${count.index}"
  subscription_id      = local.subscription_assignments[count.index].id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = local.subscription_assignments[count.index].display_name
  location             = var.location

  dynamic "identity" {
    for_each = var.create_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  not_scopes = local.subscription_assignments[count.index].not_scopes
  parameters = local.subscription_assignments[count.index].parameters
}
