# Define this module's input variables here. Every variable should set both
# `type` and `description` — terraform-docs renders this module's README.md
# from these, so an undocumented variable produces an undocumented module.
#
# Consider adding a `validation` block for inputs with constraints (allowed
# values, format, ranges, etc.) so callers get a clear error at `tofu plan`
# time instead of a confusing failure deeper in the module.
#
# variable "example" {
#   type        = string
#   description = "TODO: describe this input"
#
#   validation {
#     condition     = length(var.example) > 0
#     error_message = "example must not be empty."
#   }
# }
