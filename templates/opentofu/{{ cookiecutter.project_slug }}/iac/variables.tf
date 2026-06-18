variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID to which resources will be deployed"
{%- if cookiecutter.subscription_id %}
  default     = "{{ cookiecutter.subscription_id }}"
{%- endif %}
}

variable "slug" {
  type        = string
  description = "A short 'one-word' identifier for your deployment"
  default     = "{{ cookiecutter.project_slug }}"
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created"
  default     = "{{ cookiecutter.azure_region }}"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources"
  default     = {}
}
