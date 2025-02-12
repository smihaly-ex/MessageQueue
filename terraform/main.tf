data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
    name     = "message-resource-group"
    location = "West Europe"
}

resource "azurerm_storage_account" "storage" {
    name                     = "stracc2002unique"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "queue" {
    name                 = "message-queue"
    storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_user_assigned_identity" "functions" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "mi-message-queue-dev-fn"
}

resource "azurerm_service_plan" "plan" {
    name                = "message-queue-service-plan"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type             = "Linux"
    sku_name            = "Y1" # Consumption plan for serverless functions
}

resource "azurerm_linux_function_app" "sender_function" {
    name                       = "sender-function-app"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    service_plan_id            = azurerm_service_plan.plan.id
    storage_account_name       = azurerm_storage_account.storage.name
    storage_account_access_key = azurerm_storage_account.storage.primary_access_key

    site_config {}

    app_settings = {
        "AzureWebJobsStorage"        = azurerm_storage_account.storage.primary_connection_string
        "FUNCTIONS_WORKER_RUNTIME"   = "dotnet-isolated"
        "QUEUE_NAME"                 = azurerm_storage_queue.queue.name
        "WEBSITE_RUN_FROM_PACKAGE"   = 1
    }

    identity {
        type         = "SystemAssigned, UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.functions.id]
    }
}

resource "azurerm_linux_function_app" "receiver_function" {
    name                       = "receiver-function-app"
    resource_group_name        = azurerm_resource_group.rg.name
    location                   = azurerm_resource_group.rg.location
    service_plan_id            = azurerm_service_plan.plan.id
    storage_account_name       = azurerm_storage_account.storage.name
    storage_account_access_key = azurerm_storage_account.storage.primary_access_key

    site_config {}

    app_settings = {
        "AzureWebJobsStorage"        = azurerm_storage_account.storage.primary_connection_string
        "FUNCTIONS_WORKER_RUNTIME"   = "dotnet-isolated"
        "QUEUE_NAME"                 = azurerm_storage_queue.queue.name
        "WEBSITE_RUN_FROM_PACKAGE"   = 1
    }

    identity {
        type         = "SystemAssigned, UserAssigned"
        identity_ids = [azurerm_user_assigned_identity.functions.id]
    }
}