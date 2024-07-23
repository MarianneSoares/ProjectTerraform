#!/bin/bash

set -e

LOG_FILE=/var/log/cloud-init-docker.log

# Função para logar mensagens
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

log "Iniciando script cloud-init"

# Atualizar o índice de pacotes apt e instalar pacotes para permitir que o apt use um repositório via HTTPS
log "Atualizando o índice de pacotes apt"
apt-get update >> $LOG_FILE 2>&1

log "Instalando pacotes para permitir que o apt use um repositório via HTTPS"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common >> $LOG_FILE 2>&1

# Adicionar a chave GPG oficial do Docker
log "Adicionando a chave GPG oficial do Docker"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - >> $LOG_FILE 2>&1

# Configurar o repositório estável
log "Configurando o repositório estável"
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" >> $LOG_FILE 2>&1

# Instalar o Docker Engine
log "Instalando o Docker Engine"
apt-get update >> $LOG_FILE 2>&1
apt-get install -y docker-ce docker-ce-cli containerd.io >> $LOG_FILE 2>&1

# Adicionar o usuário ao grupo docker
log "Adicionando o usuário ao grupo docker"
usermod -aG docker azureuser >> $LOG_FILE 2>&1

# Instalar o Docker Compose
log "Instalando o Docker Compose"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> $LOG_FILE 2>&1
chmod +x /usr/local/bin/docker-compose >> $LOG_FILE 2>&1

# Habilitar o serviço Docker
log "Habilitando o serviço Docker"
systemctl enable docker >> $LOG_FILE 2>&1

# Garantir que o arquivo docker-compose.yml esteja presente
if [ ! -f /home/azureuser/docker-compose.yml ]; then
  log "Arquivo docker-compose.yml não encontrado em /home/azureuser"
  exit 1
fi

# Alterar a propriedade do arquivo docker-compose.yml
log "Alterando a propriedade do arquivo docker-compose.yml"
chown azureuser:azureuser /home/azureuser/docker-compose.yml >> $LOG_FILE 2>&1

# Executar o Docker Compose
log "Executando o Docker Compose"
cd /home/azureuser
sudo -u azureuser /usr/local/bin/docker-compose up -d >> $LOG_FILE 2>&1

# Verificar se os containers estão em execução
log "Verificando se os containers Docker estão em execução"
if sudo docker ps | grep -q 'wordpress'; then
  log "Container WordPress está em execução"
else
  log "Container WordPress NÃO está em execução"
fi

if sudo docker ps | grep -q 'mysql'; then
  log "Container MySQL está em execução"
else
  log "Container MySQL NÃO está em execução"
fi

log "Script cloud-init finalizado"
