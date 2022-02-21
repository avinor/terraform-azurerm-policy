terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.97.0"
    }
  }
}
provider "azurerm" {
  features {}
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


resource "azurerm_management_group_policy_assignment" "policy" {
  count                = length(var.management_group_assignments)
  name                 = "${var.name}-${count.index}"
  management_group_id  = var.management_group_assignments[count.index].management_group_id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.management_group_assignments[count.index].display_name
  location             = var.location

  identity {
    type = var.create_identity ? "SystemAssigned" : "None"
  }

  not_scopes = var.management_group_assignments[count.index].not_scopes
  parameters = var.management_group_assignments[count.index].parameters
}

resource "azurerm_resource_group_policy_assignment" "policy" {
  count                = length(var.resource_group_assignments)
  name                 = "${var.name}-${count.index}"
  resource_group_id    = var.resource_group_assignments[count.index].resource_group_id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.resource_group_assignments[count.index].display_name
  location             = var.location

  identity {
    type = var.create_identity ? "SystemAssigned" : "None"
  }

  not_scopes = var.resource_group_assignments[count.index].not_scopes
  parameters = var.resource_group_assignments[count.index].parameters
}

resource "azurerm_resource_policy_assignment" "policy" {
  count                = length(var.resource_assignments)
  name                 = "${var.name}-${count.index}"
  resource_id          = var.resource_assignments[count.index].resource_id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.resource_assignments[count.index].display_name
  location             = var.location

  identity {
    type = var.create_identity ? "SystemAssigned" : "None"
  }

  not_scopes = var.resource_assignments[count.index].not_scopes
  parameters = var.resource_assignments[count.index].parameters
}

resource "azurerm_subscription_policy_assignment" "policy" {
  count                = length(var.subscription_assignments)
  name                 = "${var.name}-${count.index}"
  subscription_id      = var.subscription_assignments[count.index].subscription_id
  policy_definition_id = local.definition_id
  description          = var.description
  display_name         = var.subscription_assignments[count.index].display_name
  location             = var.location

  identity {
    type = var.create_identity ? "SystemAssigned" : "None"
  }

  not_scopes = var.subscription_assignments[count.index].not_scopes
  parameters = var.subscription_assignments[count.index].parameters
}