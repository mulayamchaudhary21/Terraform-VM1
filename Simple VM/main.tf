terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.43.0"
    }
  }
}

provider "azurerm" {
  features {}
    subscription_id="99efb9ba-0c51-4e14-8bb4-3f5917cdbec8"

}
resource "azurerm_resource_group" "myrg"{
  name="ril-rg"
  location="east us"
}

  resource "azurerm_public_ip" "rilpip" {
  name                = "ril-pip"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  allocation_method   = "Static"
}
resource "azurerm_virtual_network" "rilvnet" {
  name                = "ril-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "examplerilsubnet" {
  name                 = "ril-subnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.rilvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "ril_nic" {
  name                = "ril-nic"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/99efb9ba-0c51-4e14-8bb4-3f5917cdbec8/resourceGroups/ril-rg/providers/Microsoft.Network/virtualNetworks/ril-vnet/subnets/ril-subnet"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "/subscriptions/99efb9ba-0c51-4e14-8bb4-3f5917cdbec8/resourceGroups/ril-rg/providers/Microsoft.Network/publicIPAddresses/ril-pip"
  }
}

resource "azurerm_linux_virtual_machine" "ril_vm" {
  name                = "ril-vm"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password = "Admin@1234"
  network_interface_ids = ["/subscriptions/99efb9ba-0c51-4e14-8bb4-3f5917cdbec8/resourceGroups/ril-rg/providers/Microsoft.Network/networkInterfaces/ril-nic"]
disable_password_authentication = false
   
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}