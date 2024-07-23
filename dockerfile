# Use a imagem oficial do WordPress como base
FROM wordpress:latest

# Copie arquivos adicionais, se necessário
# COPY ./custom-php.ini /usr/local/etc/php/conf.d/

# Exponha a porta 80
EXPOSE 80

# Comando de inicialização padrão
CMD ["apache2-foreground"]
