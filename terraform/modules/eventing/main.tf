resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_eventgrid_topic" "this" {
  name                = "${var.name_prefix}-topic"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
}

resource "azurerm_servicebus_namespace" "this" {
  name                = "${var.name_prefix}-sb-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Standard"
  minimum_tls_version = "1.2"
}

resource "azurerm_servicebus_queue" "this" {
  name                                 = "events"
  namespace_id                         = azurerm_servicebus_namespace.this.id
  dead_lettering_on_message_expiration = true
}

resource "azurerm_eventgrid_event_subscription" "to_servicebus" {
  name                          = "${var.name_prefix}-to-sb"
  scope                         = azurerm_eventgrid_topic.this.id
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.this.id

  retry_policy {
    max_delivery_attempts = 30
    event_time_to_live    = 1440
  }
}

resource "azurerm_storage_account" "this" {
  name                            = "${replace(var.name_prefix, "-", "")}st${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.this.name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "this" {
  name                = "${var.name_prefix}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "this" {
  name                = "${var.name_prefix}-func-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    ftps_state          = "Disabled"
    application_stack {
      node_version = "20"
    }
  }

  app_settings = {
    SERVICEBUS_NAMESPACE = azurerm_servicebus_namespace.this.name
    SERVICEBUS_QUEUE     = azurerm_servicebus_queue.this.name
  }
}
