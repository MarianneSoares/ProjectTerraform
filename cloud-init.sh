#!/bin/bash

LOG_FILE="/var/log/cloud-init-script.log"


exec > >(tee -a $LOG_FILE) 2>&1

echo "=== Início do Script de Inicialização ==="

echo "Atualizando o sistema..."
sudo apt-get update -y

echo "Instalando pacotes necessários..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

echo "Adicionando a chave GPG do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo "Adicionando o repositório do Docker..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

echo "Instalando o Docker..."
sudo apt-get update -y
sudo apt-get install -y docker-ce

echo "Iniciando o Docker..."
sudo systemctl start docker

echo "Adicionando o usuário atual ao grupo do Docker..."
sudo usermod -aG docker azureuser

DOCKER_COMPOSE_VERSION="1.29.2"
echo "Instalando o Docker Compose versão $DOCKER_COMPOSE_VERSION..."
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Criando diretório para os arquivos Docker..."
mkdir -p /home/azureuser/docker-setup

echo "Criando arquivo docker-compose.yml a partir de conteúdo base64..."
cat <<EOF | base64 -d > /home/azureuser/docker-setup/docker-compose.yml
dmVyc2lvbjogJzMuOCcNCg0Kc2VydmljZXM6DQogIHdvcmRwcmVzczoNCiAgICBidWlsZDoNCiAgICAgIGNvbnRleHQ6IC4NCiAgICAgIGRvY2tlcmZpbGU6IERvY2tlcmZpbGUNCiAgICBjb250YWluZXJfbmFtZTogd29yZHByZXNzDQogICAgcG9ydHM6DQogICAgICAtICI4MDo4MCINCiAgICBlbnZpcm9ubWVudDoNCiAgICAgIFdPUkRQUkVTU19EQl9IT1NUOiBkYg0KICAgICAgV09SRFBSRVNTX0RCX1VTRVI6IHdvcmRwcmVzcw0KICAgICAgV09SRFBSRVNTX0RCX1BBU1NXT1JEOiBHQXVkNG1aYnk4RjNTRDZQDQogICAgICBXT1JEUFJFU1NfREJfTkFNRTogd29yZHByZXNzDQogICAgdm9sdW1lczoNCiAgICAgIC0gd29yZHByZXNzX2RhdGE6L3Zhci93d3cvaHRtbA0KDQogIGRiOg0KICAgIGltYWdlOiBteXNxbDo1LjcNCiAgICBjb250YWluZXJfbmFtZTogbXlzcWwNCiAgICBlbnZpcm9ubWVudDoNCiAgICAgIE1ZU1FMX1JPT1RfUEFTU1dPUkQ6IEdBdWQ0bVpieThGM1NENlANCiAgICAgIE1ZU1FMX0RBVEFCQVNFOiB3b3JkcHJlc3MNCiAgICAgIE1ZU1FMX1VTRVI6IHdvcmRwcmVzcw0KICAgICAgTVlTUUxfUEFTU1dPUkQ6IEdBdWQ0bVpieThGM1NENlANCiAgICB2b2x1bWVzOg0KICAgICAgLSBkYl9kYXRhOi92YXIvbGliL215c3FsDQoNCnZvbHVtZXM6DQogIHdvcmRwcmVzc19kYXRhOiB7fQ0KICBkYl9kYXRhOiB7fQ0K
EOF

echo "Criando arquivo Dockerfile a partir de conteúdo base64..."
cat <<EOF | base64 -d > /home/azureuser/docker-setup/Dockerfile
IyBVc2UgYSBpbWFnZW0gb2ZpY2lhbCBkbyBXb3JkUHJlc3MgY29tbyBiYXNlDQpGUk9NIHdvcmRwcmVzczpsYXRlc3QNCg0KIyBFeHBvbmhhIGEgcG9ydGEgODANCkVYUE9TRSA4MA0K
EOF

echo "Navegando até o diretório /home/azureuser/docker-setup..."
cd /home/azureuser/docker-setup

echo "Construindo e subindo os containers..."
sudo docker-compose up -d

echo "=== Fim do Script de Inicialização ==="