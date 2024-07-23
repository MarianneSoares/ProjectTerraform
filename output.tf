#Este arquivo define as saídas do terraform, neste caso o IP público da VM. 
output "public_ip" {
  description = "IP publico da maquina virtual"
  value       = azurerm_public_ip.public_ip_wordpress.ip_address
}