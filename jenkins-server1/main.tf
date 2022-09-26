# Create resource group if it doesnt exit

resource "azurerm_resource_group" "rg" {
  name     = "rg-02"
  location = "eastus"
}

# Create Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-02"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create Subnet

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-02"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define new Public IP

resource "azurerm_public_ip" "publicip" {
  name                = "pip-02"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-02"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

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

  security_rule {
    name                       = "http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the network security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Define NIC for VM

resource "azurerm_network_interface" "nic" {
  name                = "nic-02"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig-02"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# Create (and display) an SSH key

resource "tls_private_key" "ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "tls_private_key" {
  value     = tls_private_key.ssh-key.private_key_pem
  sensitive = true
}

# Create VM

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "jenkins-server1"
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  location                        = "eastus"
  size                            = "Standard_B1s"
  admin_username                  = "rahul"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "rahul"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  
  connection {
    host        = self.public_ip_address
    user        = "rahul"
    type        = "ssh"
    private_key = file("~/.ssh/id_rsa")
    timeout     = "4m"
    agent       = false
  }

  provisioner "file" {
    source      = "jenkins-setup.sh"
    destination = "/tmp/jenkins-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/jenkins-setup.sh",
      "sudo bash /tmp/jenkins-setup.sh",
    ]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

}