variable "name" {
  description = "Short name of this policy assignment."
}

variable "description" {
  description = "Description of what this policy does. Added to both definition and assignment."
}

variable "location" {
  description = "The Azure Region in which to create resource."
}

variable "create_identity" {
  description = "Set to true to create a system assigned managed identity. Required for policies that use deploy effect."
  type        = bool
  default     = false
}

variable "custom_policy" {
  description = "A custom policy to create, will overwrite policy_definition_id. Both cannot be configured at same time."
  type        = object({ display_name = string, mode = string, management_group_id = string, metadata = string, policy_rule = string, parameters = string })
  default     = null
}

variable "policy_definition_id" {
  description = "The ID of the Policy Definition to be applied at the scope. If `custom_policy` variable is defined it will ignore this."
  default     = null
}

variable "assignments" {
  description = "A list of policies to assign to scope."
  type        = list(object({ display_name = string, scope = string, not_scopes = list(string), parameters = string }))
}