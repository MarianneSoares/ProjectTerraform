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
  depends_on          = [azurerm_resource_group.rg_wordpress]
}

# Cria uma sub-rede utilizando o nome e prefixo de endereço definidos nas variáveis
# dentro da rede virtual e grupo de recursos definidos anteriormente
resource "azurerm_subnet" "subnet_wordpress" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg_wordpress.name
  virtual_network_name = azurerm_virtual_network.vnet_wordpress.name
  address_prefixes     = var.subnet_address_prefixes
  depends_on           = [azurerm_virtual_network.vnet_wordpress]
}

# Cria um endereço IP público definidos nas variáveis
# na mesma localização e grupo de recursos definidos anteriormente
resource "azurerm_public_ip" "public_ip_wordpress" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_resource_group.rg_wordpress]
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

  depends_on = [
    azurerm_subnet.subnet_wordpress,
    azurerm_public_ip.public_ip_wordpress
  ]
}

# Cria um grupo de segurança de rede utilizando o nome definido nas variáveis
resource "azurerm_network_security_group" "nsg_wordpress" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rg_wordpress.location
  resource_group_name = azurerm_resource_group.rg_wordpress.name

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

  depends_on = [azurerm_resource_group.rg_wordpress]
}

# Associa a interface de rede ao grupo de segurança de rede 
resource "azurerm_network_interface_security_group_association" "nsg_assoc_wordpress" {
  network_interface_id      = azurerm_network_interface.nic_wordpress.id
  network_security_group_id = azurerm_network_security_group.nsg_wordpress.id

  depends_on = [
    azurerm_network_interface.nic_wordpress,
    azurerm_network_security_group.nsg_wordpress
  ]
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
    custom_data    = filebase64("cloud-init.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = file("${path.module}/.ssh/id_rsa.pub")
    }
  }

  tags = {
    environment = var.environment
  }

  depends_on = [azurerm_network_interface.nic_wordpress]
}
