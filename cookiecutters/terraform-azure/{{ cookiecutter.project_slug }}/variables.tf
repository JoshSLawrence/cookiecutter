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
}
