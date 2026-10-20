output "eventgrid_topic_endpoint" {
  description = "Event Grid topic endpoint (publish events here)"
  value       = azurerm_eventgrid_topic.this.endpoint
}

output "servicebus_namespace" {
  description = "Service Bus namespace"
  value       = azurerm_servicebus_namespace.this.name
}

output "function_app_hostname" {
  description = "Consumer Function App hostname"
  value       = azurerm_linux_function_app.this.default_hostname
}
