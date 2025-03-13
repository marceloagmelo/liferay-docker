
# Liferay em Docker

Esse projeto contempla um ambiente do liferay rodando em container docker.

## Pré-Requisitos

1.  Instalar o docker
2.  Instalar o docker-compose
3.  Instalar o blade

## Execução

### Iniciar:

`./liferay_command init`

Este comando irá levantar os containers abaixo e executar os builds dos módulos e temas se existirem:
- Mysql
- Adminer: Administrador de banco de dados
- Elasticsearch
- Nginx
- Liferay

### Levantar  Containers:

`./liferay_command.sh start`

Este comando irá apenas levantar os containers.

### Derrumar  Containers:

`./liferay_command.sh stop`

Este comando irá apenas derrubar os containers.

###  Backup:

`./liferay_command.sh backup`

Este comando irá realizar o backup do banco de dados e do file system do liferay e copiar para a pasrta backups com os seguintes nomes:
- document_libray.zip
- database.zip

###  Restore:

`./liferay_command.sh restore`

Este comando irá realizar o restore com os arquivos gerados no backup com os nomes abaixo:
- document_libray.zip
- database.zip

###  Deploy:

`./liferay_command.sh deploy`

Este comando irá executar os builds dos módulos e temas se existirem:

###  Clean:

`./liferay_command.sh clean`

Este comando irá derrubar os containers e remover os seguintes diretórios:
- bundles
- build
- node_modules
- node_modules_cache
- backups
- dump/mysql.sql

Também irã remover o arquivo *mysql.sql* da pasta *dump*.

###  Logs:

`./liferay_command.sh logs`

Este comando irá exibir o log do container liferay.
