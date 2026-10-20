locals {
  name = var.project_name
  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Owner     = "Muhammad Ahmad"
  }
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = local.tags
}

############################
# Event Grid topic (ingress)
############################
resource "azurerm_eventgrid_topic" "this" {
  name                = "${local.name}-topic"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}

############################
# Service Bus (durable queue)
############################
resource "azurerm_servicebus_namespace" "this" {
  name                = "${local.name}-sb-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_servicebus_queue" "this" {
  name         = "events"
  namespace_id = azurerm_servicebus_namespace.this.id
}

############################
# Route Event Grid -> Service Bus queue
############################
resource "azurerm_eventgrid_event_subscription" "to_servicebus" {
  name  = "${local.name}-to-sb"
  scope = azurerm_eventgrid_topic.this.id

  service_bus_queue_endpoint_id = azurerm_servicebus_queue.this.id
}

############################
# Function App (consumer)
############################
resource "azurerm_storage_account" "this" {
  name                     = "${replace(var.project_name, "-", "")}st${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_service_plan" "this" {
  name                = "${local.name}-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = "${local.name}-func-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id

  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key

  site_config {
    application_stack {
      node_version = "20"
    }
  }

  app_settings = {
    SERVICEBUS_NAMESPACE = azurerm_servicebus_namespace.this.name
    SERVICEBUS_QUEUE     = azurerm_servicebus_queue.this.name
  }

  tags = local.tags
}
