provider "azurerm" {
  features {}

  # Utiliza variáveis de ambiente para autenticação no Azure
  # As seguintes variáveis de ambiente devem ser definidas:
  # - ARM_SUBSCRIPTION_ID: O ID da assinatura do Azure
  # - ARM_CLIENT_ID: O ID do cliente (aplicativo) registrado no Azure AD
  # - ARM_CLIENT_SECRET: O segredo do cliente (aplicativo) registrado no Azure AD
  # - ARM_TENANT_ID: O ID do locatário (tenant) do Azure AD

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}