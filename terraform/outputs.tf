output "eventgrid_topic_endpoint" {
  value = module.eventing.eventgrid_topic_endpoint
}
output "servicebus_namespace" {
  value = module.eventing.servicebus_namespace
}
output "function_app_hostname" {
  value = module.eventing.function_app_hostname
}
