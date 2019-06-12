variable "management_group_id" {
    description = "Management group id where the custom policies should be created. Required if policies is defined."
    default = null
}

variable "policies" {
    description = "A list of custom policies to apply to management group defined by `management_group_id`."
    type = list(object({ name = string, description = string, mode = string, policy_rule = string, metadata = string, parameters = string }))
    default = []
}

variable "assignments" {
    description = "A list of policies to assign to scope."
    type = list(object({ name = string, description = string, definition_id = string, parameters = string, not_scopes = list(string) }))
}