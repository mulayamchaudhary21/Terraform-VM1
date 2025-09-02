resource "azurerm_resource_group" "my-rg" {
  for_each = var.linux_vm
  name     = "monalrg"
  location = "west india"
}
resource "azurerm_public_ip" "public_pip" {
  for_each            = var.linux_vm
  name                = each.value.pipname
  resource_group_name = each.value.rgname
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"

  }

}
data "azurerm_subnet" "frontend_subnet" {
  for_each             = var.linux_vm
  name                 = each.value.subnetname
  virtual_network_name = each.value.vnetname
  resource_group_name  = each.value.rgname

}
resource "azurerm_network_interface" "frontend-nic" {
  for_each            = var.linux_vm
  name                = each.value.nicname
  location            = each.value.location
  resource_group_name = each.value.rgname
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.frontend_subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_pip[each.key].id
  }
}
resource "azurerm_linux_virtual_machine" "example" {
  for_each                        = var.linux_vm
  name                            = each.value.vmname
  resource_group_name             = each.value.rgname
  location                        = each.value.location
  size                            = each.value.size
  admin_username                  = each.value.username
  admin_password                  = each.value.password
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.frontend-nic[each.key].id,
  ]

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
