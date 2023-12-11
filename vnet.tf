provider "azurerm" {
  features {}
  subscription_id = ""
  tenant_id = ""
}

resource "azurerm_resource_group" "testresourcegroup" {
  name = "testresourcegroup"
  location = "Japan West"
}

resource "azurerm_virtual_network" "testvnet" {
  name = "testvnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.testresourcegroup.location
  resource_group_name = azurerm_resource_group.testresourcegroup.name
}

resource "azurerm_subnet" "test_subnet" {
  name = "testsubnet"
  resource_group_name = azurerm_resource_group.testresourcegroup.name
  virtual_network_name = azurerm_virtual_network.testvnet.name
  address_prefixes = [ "10.0.0.0/24" ]
}