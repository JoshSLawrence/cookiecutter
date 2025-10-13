{% if cookiecutter.use_azure_provider %}variable "slug" {
  type        = string
  description = "A short 'one-word' identifier for your deployment."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
  default     = "{{ cookiecutter._defaults.region_azure }}"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription to which resources will be deployed"
} {% endif %}
