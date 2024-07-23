# Cria um grupo de recursos usando o nome e a localização definidos nas variáveis
resource "azurerm_resource_group" "rg_wordpress" {
  name     = var.resource_group_name
  location = var.location
}

# Cria uma rede virtual utilizando o nome e espaço de endereçamento definidos nas variáveis 
#na mesma localização e grupo de recursos definidos anteriormente
resource "azurerm_virtual_network" "vnet_wordpress" {
  name                = var.virtual_network_name
  address_space       = var.address_space
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name
}

# Cria uma sub-rede utilizando o nome e prefixo de endereço definidos nas variáveis
# dentro da rede virtual e grupo de recursos definidos anteriormente
resource "azurerm_subnet" "subnet_wordpress" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg_wordpress.name
  virtual_network_name = azurerm_virtual_network.vnet_wordpress.name
  address_prefixes     = var.subnet_address_prefixes
}

# Cria um endereço IP público definidos nas variáveis
# na mesma localização e grupo de recursos definidos anteriormente
resource "azurerm_public_ip" "public_ip_wordpress" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Cria uma interface de rede utilizando o nome definido nas variáveis
# associada à sub-rede e endereço IP público definidos anteriormente
resource "azurerm_network_interface" "nic_wordpress" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_wordpress.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_wordpress.id
  }
}

# Cria um grupo de segurança de rede utilizando o nome definido nas variáveis
resource "azurerm_network_security_group" "nsg_wordpress" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name
# com regras de segurança para SSH e HTTP, permitindo tráfego de entrada nas portas 22 (SSH) e 80 (HTTP)
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
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associa a interface de rede ao grupo de segurança de rede 
resource "azurerm_network_interface_security_group_association" "nsg_assoc_wordpress" {
  network_interface_id      = azurerm_network_interface.nic_wordpress.id
  network_security_group_id = azurerm_network_security_group.nsg_wordpress.id
}

# Cria uma máquina virtual utilizando o nome, tamanho, e outras configurações definidas nas variáveis
# associada à interface de rede e utilizando uma imagem do Ubuntu 18.04-LTS
resource "azurerm_virtual_machine" "vm_wordpress" {
  name                  = var.vm_name
  location              = azurerm_resource_group.rg_wordpress.location
  resource_group_name   = azurerm_resource_group.rg_wordpress.name
  network_interface_ids = [azurerm_network_interface.nic_wordpress.id]
  vm_size               = var.vm_size

  storage_os_disk {
    name              = var.os_disk_name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm_name
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = filebase64("setup-docker.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = var.environment
  }
}

# Provisionamento do arquivo docker-compose.yml para a VM
resource "null_resource" "copy_docker_compose" {
  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/home/azureuser/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = azurerm_public_ip.public_ip_wordpress.ip_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chown azureuser:azureuser /home/azureuser/docker-compose.yml"
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      password    = var.admin_password
      host        = azurerm_public_ip.public_ip_wordpress.ip_address
    }
  }

  depends_on = [
    azurerm_virtual_machine.vm_wordpress
  ]
}