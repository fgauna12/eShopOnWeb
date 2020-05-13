provider "azurerm" {
  version = "~>2.0.0"
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "rg-eshoponwebonazure-staging"
  location = "eastus"

  tags = {
    CreatedBy = "terraform"
    CreatedOn = timestamp()
  }
}

module "webapp" {
  source = "github.com/NewSignature/afterburn//iac/modules/web-app"

  sku_tier    = "Basic"
  sku_size    = "B1"
  environment = "test"
  location    = "eastus"
  app_name    = "eshoponwebonazure"

  app_settings = {
    ASPNETCORE_ENVIRONMENT= "Development"
  }
}

output "resource_group_name" {
  value = module.webapp.resource_group_name
}

output "app_service_name" {
  value = module.webapp.app_service_name
}

output "app_service_hostname" {
  value = module.webapp.app_service_hostname
}