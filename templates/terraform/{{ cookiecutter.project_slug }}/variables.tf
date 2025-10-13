variable "slug" {
  type        = string
  description = "An identifier for your deployment."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}{% if cookiecutter.is_config_or_module == "config" %}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription to which resources will be deployed"
}{% endif %}
