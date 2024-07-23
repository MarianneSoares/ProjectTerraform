variable "resource_group_name" {
  description = "O nome do grupo de recursos"
  type        = string
  default     = "rg-wordpress"
}

variable "location" {
  description = "A localização dos recursos"
  type        = string
  default     = "West US"
}

variable "virtual_network_name" {
  description = "O nome da rede virtual"
  type        = string
  default     = "vnet-wordpress"
}

variable "address_space" {
  description = "O endereçamento para a rede virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "O nome da sub-rede"
  type        = string
  default     = "subnet-wordpress"
}

variable "subnet_address_prefixes" {
  description = "Os prefixos de endereço para a sub-rede"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_ip_name" {
  description = "O nome do IP público"
  type        = string
  default     = "public-ip-wordpress"
}

variable "network_interface_name" {
  description = "O nome da interface de rede"
  type        = string
  default     = "nic-wordpress"
}

variable "network_security_group_name" {
  description = "O nome do grupo de segurança de rede"
  type        = string
  default     = "nsg-wordpress"
}

variable "vm_name" {
  description = "O nome da máquina virtual"
  type        = string
  default     = "vm-wordpress"
}

variable "vm_size" {
  description = "O tamanho da máquina virtual"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "os_disk_name" {
  description = "O disco do sistema operacional"
  type        = string
  default     = "osdisk-wordpress"
}

variable "admin_username" {
  description = "O nome de usuário admin para a VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "A senha do administrador para a VM"
  type        = string
  default     = "GAud4mZby8F3SD6P"
}
variable "environment" {
  description = "A tag de ambiente para os recursos"
  type        = string
  default     = "Terraform"
}

variable "subscription_id" {
  description = "O ID da assinatura do Azure"
  type        = string
  default     = ""  # vazio para usar a variável de ambiente ARM_SUBSCRIPTION_ID
}

variable "client_id" {
  description = "O ID do cliente (aplicativo) registrado no Azure AD"
  type        = string
  default     = ""  # vazio para usar a variável de ambiente ARM_CLIENT_ID
}

variable "client_secret" {
  description = "O segredo do cliente (aplicativo) registrado no Azure AD"
  type        = string
  default     = ""  # vazio para usar a variável de ambiente ARM_CLIENT_SECRET
}

variable "tenant_id" {
  description = "O ID do locatário (tenant) do Azure AD"
  type        = string
  default     = ""  # vazio para usar a variável de ambiente ARM_TENANT_ID
}