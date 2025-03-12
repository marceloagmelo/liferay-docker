#
# Deve-se selecionar a mesma imagem usada no DXP Cloud
#
FROM liferay/portal:7.4.3.132-ga132
#
# Copia os arquivos da pasta common e docker-compose, para configuração
# da plataforma
#
COPY --chown=liferay:liferay configs/common /mnt/liferay/files
COPY --chown=liferay:liferay configs/docker-compose /mnt/liferay/files
