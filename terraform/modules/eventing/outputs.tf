output "eventgrid_topic_endpoint" {
  value = azurerm_eventgrid_topic.this.endpoint
}
output "servicebus_namespace" {
  value = azurerm_servicebus_namespace.this.name
}
output "function_app_hostname" {
  value = azurerm_linux_function_app.this.default_hostname
}
