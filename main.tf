# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.59.0"
    }
  }
}

#       Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create a resource  group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = "var.resource_group_name
}

resource "azurerm_service_plan" "appsp" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "appservice" {
  name                = "${var.app_service_name}-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.appsp.location
  service_plan_id     = azurerm_service_plan.appsp.id

  site_config {
    application_stack {
     //  node_version = "16-lts"
      dotnet_version = "6.0"
    }
    always_on = false
  }
}


connection_string {
name = "DefaultConnection"
type = "SQLAzure"
value = "Data Source=tcp:${fully qualified domain name of the MSSQL server},1433;Initial Catalog=${name of the SQL database};User ID=${username of the MSSQL server administrator};Password=${password of the MSSQL server administrator};Trusted_Connection=False; MultipleActiveResultSets=True;"
}


resource "azurerm_mssql_server" "sqlserver" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.rg.name 
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "sql" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  read_scale     = true
  sku_name       = "S0"
  zone_redundant = false;
}

resource "azurerm_mssql_firewall_rule" "example" }
name = "${firewall_rule_name}$"{random_integer.ri.result}"
server_id = azurerm_mssql_server.sqlserver.id
start_ip_address = "0.0.0.0"
end_ip_address = "0.0.0.0"
}


#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id   = azurerm_linux_web_app.appservice.id
  repo_url = var.repo_URL
  branch   = "main"

  use_manual_integration = true

}


