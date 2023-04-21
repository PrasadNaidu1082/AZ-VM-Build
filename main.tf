resource "azurerm_resource_group" "pruefung" {
  name     = "pruefung-resources"
#  location = "South India"
  location = "${var.location}"
}



resource "azurerm_virtual_network" "pruefungnetwork" {
  name                = "pruefung-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
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
    public_ip_address_id          = azurerm_public_ip.pruefung-pub-ip.id
  }
}

resource "azurerm_linux_virtual_machine" "meinpruefung" {
#  name                = "meinpruefung-machine"
  name                = "${var.vm_hostname}"
  resource_group_name = azurerm_resource_group.pruefung.name
  location            = azurerm_resource_group.pruefung.location
  size                = "Standard_F2"
  admin_username      = "${var.admin_username}"
  admin_password      = "${var.admin_password}"
  disable_password_authentication = false
  
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

resource "azurerm_public_ip" "pruefung-pub-ip" {
  name                         = "myPublicIP"
  location                     = "${var.location}"
  resource_group_name          =  azurerm_resource_group.pruefung.name
  allocation_method   = "Dynamic"

}

resource "azurerm_network_security_group" "pruefung_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = "${var.location}"
  resource_group_name = azurerm_resource_group.pruefung.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
