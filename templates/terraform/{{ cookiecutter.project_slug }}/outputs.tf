output "resoruce_group_name" {
  value = azurerm_resource_group.this.name
}

output "location" {
  value = var.location
}
