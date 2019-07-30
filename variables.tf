variable "name" {
  description = "Short name of this policy assignment."
}

variable "description" {
  description = "The Azure Region in which to create resource."
}

variable "location" {
  description = "The Azure Region in which to create resource."
}

variable "scope" {
    description = "The Scope at which the Policy Assignment should be applied."
}

variable "custom_policy" {
    description = "A custom policy to create and apply to management group defined by `management_group_id`."
    type = object({ name = string, description = string, mode = string, policy_rule = string, metadata = string, parameters = string })
    default = {}
}

variable "policy_definition_id" {
    description = "The ID of the Policy Definition to be applied at the scope. If `custom_policy` variable is defined it will ignore this."
    default = null
}

variable "assignments" {
    description = "A list of policies to assign to scope."
    type = list(object({ parameters = string, scope = string, not_scopes = list(string) }))
}