resource "azurerm_resource_group" "prod" {
  name     = "RG${var.BaseName}"
  location = var.Location
}

resource "azurerm_storage_account" "prod" {
  name                     = "${var.StorageAccountName}"
  resource_group_name      = azurerm_resource_group.prod.name
  location                 = azurerm_resource_group.prod.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "prod" {
  name                 = "messagedrop"
  storage_account_name = azurerm_storage_account.prod.name
}

resource "azurerm_app_service_plan" "prod" {
  name                = "${var.BaseName}MessageReaderEnginePlan"
  location            = azurerm_resource_group.prod.location
  resource_group_name = azurerm_resource_group.prod.name
  kind                = "FunctionApp"
  
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "null_resource" "prod" {
  provisioner "local-exec" {
      command =  "az functionapp create --name ${var.BaseName}MessageReaderEngine --storage-account ${azurerm_storage_account.prod.name} --consumption-plan-location ${azurerm_resource_group.prod.location} --resource-group ${azurerm_resource_group.prod.name} --deployment-source-url ${var.GitInfo.RepoUrl}  --deployment-source-branch ${var.GitInfo.Branch}"
  }

  provisioner "local-exec" {
    command = "az functionapp config appsettings set --name ${var.BaseName}MessageReaderEngine --resource-group ${azurerm_resource_group.prod.name} --settings TableName=${var.TableName}"
  }

  provisioner "local-exec" {
    command = "az functionapp restart --name ${var.BaseName}MessageReaderEngine --resource-group ${azurerm_resource_group.prod.name}"
  }
  depends_on = [azurerm_app_service_plan.prod, azurerm_storage_account.prod]
}

#  provisioner "local-exec" {
#    command = <<EOT
#        "az functionapp create --name ${var.BaseName}MessageReaderEngine --storage-account ${azurerm_storage_account.prod.name} --consumption-plan-location ${azurerm_resource_group.prod.location} --resource-group ${azurerm_resource_group.prod.name} --deployment-source-url ${var.GitInfo.RepoUrl}  --deployment-source-branch ${var.GitInfo.Branch}"
#        "az functionapp config appsettings set --name ${var.BaseName}MessageReaderEngine --resource-group ${azurerm_resource_group.prod.name} --settings TableName='${var.TableName}'"
#        "az functionapp restart --name ${var.BaseName}MessageReaderEngine --resource-group ${azurerm_resource_group.prod.name}"
#    EOT
 # }


#resource "azurerm_function_app" "prod" {
#  name                      = "${var.BaseName}MessageReaderEngine"
#  location                  = azurerm_resource_group.prod.location
#  resource_group_name       = azurerm_resource_group.prod.name
#  app_service_plan_id       = azurerm_app_service_plan.prod.id
#  storage_connection_string = azurerm_storage_account.prod.primary_connection_string
#
  #app_settings = {
#    TableName           = var.TableName
#    #AzureWebJobsStorage = azurerm_app_service_plan.prod.primary_connection_string
#  }

  #provisioner "local-exec" {
  #  #command = "${join("", list("az functionapp deployment source config-local-git --ids ", azurerm_function_app.funcapp.id))}"
  #  command = "az functionapp deployment source config --branch ${var.GitInfo.Branch} --manual-integration --name ${azurerm_function_app.prod.name} --repo-url ${var.GitInfo.RepoUrl} --resource-group ${azurerm_resource_group.prod.name} --repository-type git"
  #}
#}

#resource "null_resource" "prod" {
#  provisioner "local-exec" {
#    #command = "${join("", list("az functionapp deployment source config-local-git --ids ", azurerm_function_app.funcapp.id))}"
#    command = "az functionapp deployment source config --branch ${var.GitInfo.Branch} --manual-integration --name ${azurerm_function_app.prod.name} --repo-url ${var.GitInfo.RepoUrl} --resource-group ${azurerm_resource_group.prod.name}"
#  }
#  depends_on = [azurerm_function_app.prod]
#}
