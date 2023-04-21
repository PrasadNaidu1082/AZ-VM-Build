resource "azurerm_resource_group" "pruefung" {
  name     = "pruefung-resources"
#  location = "South India"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "pruefungnetwork" {
  name                = "pruefung-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.pruefung.location
  resource_group_name = azurerm_resource_group.pruefung.name
}

resource "azurerm_subnet" "pruefungsubnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.pruefung.name
  virtual_network_name = azurerm_virtual_network.pruefungnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "pruefung" {
  name                = "pruefung-nic"
  location            = azurerm_resource_group.pruefung.location
  resource_group_name = azurerm_resource_group.pruefung.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.pruefungsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "meinpruefung" {
#  name                = "meinpruefung-machine"
  name                = "${var.vm_hostname}${count.index}"
  resource_group_name = azurerm_resource_group.pruefung.name
  location            = azurerm_resource_group.pruefung.location
  size                = "Standard_F2"
  admin_username      = "${var.admin_username}"
  admin_password      = "${var.admin_password}"
  network_interface_ids = [
    azurerm_network_interface.pruefung.id,
  ]

#admin_ssh_key {
#    username   = "adminuser"
#    public_key = file("~/.ssh/id_rsa.pub")
#  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
