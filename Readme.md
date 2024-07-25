# Deploy de WordPress na Azure com Terraform e Docker
Este projeto automatiza a criação de uma máquina virtual (VM) na Azure, instala Docker na VM e configura containers Docker para WordPress e MySQL usando Terraform.

### Pré-requisitos
Antes de começar, você precisará ter as seguintes ferramentas instaladas no seu computador:

* Terraform
* Azure CLI
* Conta no Azure com as permissões necessárias para criar recursos

## Estrutura dos Arquivos
* main.tf: Define os recursos do Azure a serem criados (grupo de recursos, rede virtual, sub-rede, IP público, interface de rede, grupo de segurança, VM).
* variables.tf: Define as variáveis usadas no projeto.
* cloud-init.sh: Script de inicialização usado para instalar Docker e configurar os containers Docker.
* docker-compose.yml: Define os serviços Docker (WordPress e MySQL).
* Dockerfile: Define a imagem Docker personalizada para o WordPress.
* output.tf: Define as saídas do Terraform (IP público da VM).
* provider.tf: Configura o provedor Azure para o Terraform.

## Configuração Inicial
### Autenticação na Azure
Autentique-se na Azure usando a Azure CLI:
`az login`

Configure a assinatura do Azure a ser usada:
`az account set --subscription "<ID_DA_ASSINATURA>"`

Configuração das Variáveis de Ambiente
Configure as seguintes variáveis de ambiente para que o Terraform possa autenticar na Azure:

`export ARM_SUBSCRIPTION_ID=<ID_DA_ASSINATURA>`
`export ARM_CLIENT_ID=<ID_DO_CLIENTE>`
`export ARM_CLIENT_SECRET=<SEGREDO_DO_CLIENTE>`
`export ARM_TENANT_ID=<ID_DO_LOCATÁRIO>`
Substitua *<ID_DA_ASSINATURA>*, *<ID_DO_CLIENTE>*, *<SEGREDO_DO_CLIENTE>*, e *<ID_DO_LOCATÁRIO>* pelos valores apropriados.

## Como Usar

### Passo 1: Clonar o Repositório
Clone este repositório no seu ambiente local:
` git clone <https://github.com/MarianneSoares/ProjectTerraform/> `
` cd <ProjectTerraform> `

### Passo 2: Revisar e Modificar Variáveis
Antes de aplicar o plano do Terraform, revise e modifique as variáveis conforme necessário. As variáveis estão definidas no arquivo variables.tf.

Para modificar uma variável, abra o arquivo variables.tf em um editor de texto e edite o valor após default =. 

Certifique-se de salvar o arquivo após fazer as alterações.

### Passo 3: Inicializar o Terraform
Inicialize o Terraform para configurar o ambiente:
`terraform init`

### Passo 4: Criar o Plano de Execução
Crie um plano de execução para verificar quais recursos serão criados:
`terraform plan`

### Passo 5: Aplicar o Plano
Aplique o plano para criar os recursos na Azure:
`terraform apply`
Digite yes quando solicitado para confirmar a criação dos recursos.

### Passo 6: Acessar o WordPress
Após a conclusão da execução do Terraform, você verá o IP público da VM nos outputs. Use este IP para acessar o WordPress no seu navegador:

http://<IP_PUBLICO>

### Limpeza
Para remover os recursos criados, execute:
`terraform destroy`
Digite yes quando solicitado para confirmar a remoção dos recursos.