#!/bin/bash

# Verificar si el script se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi
echo "Instalando Complementos"
# Complementos
apt update -y
apt upgrade -y
apt install build-essential -y
apt install gcc -y
apt install unzip -y
echo "Complementos instalados"
sleep 2
clear
# Instalar Java JDK
sudo mkdir /usr/lib/jvm/
sudo tar -zxvf jdk-8u361-linux-x64.tar.gz -C /usr/lib/jvm/
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.8.0_361/bin/java 1

java -version
sleep 2
# Instalación del entorno en Debian 12

# Crear un usuario para Tomcat
useradd -m -U -d /srv/template/tomcat -s /bin/false tomcat

# Crear carpeta para Tomcat
mkdir -p /srv/template/tomcat
chown tomcat:tomcat /srv/template/tomcat -R
# Descomprimir file
echo "descomprimiendo file y accediendo"
unzip file.zip
cd file
sleep 1
clear
# Descomprimir Apache Tomcat
TOMCAT_ARCHIVE="apache-tomcat-9.0.65.tar.gz"
tar -xf "$TOMCAT_ARCHIVE" -C /srv/template/tomcat --strip-components=1

# Instalar Amazon Corretto
CORRETTO_ARCHIVE="amazon-corretto-8.275.01.1-linux-x64.zip"
mkdir -p /usr/java
mv "$CORRETTO_ARCHIVE" /usr/java
cd /usr/java/
unzip "$CORRETTO_ARCHIVE"
ln -s /usr/java/amazon-corretto-8.275.01.1-linux-x64/ /usr/java/default
ln -s /usr/java/amazon-corretto-8.275.01.1-linux-x64/ /usr/java/latest

# Dar permisos
chmod a+rx /srv/template/tomcat/bin

# Configurar Tomcat como un servicio systemd
cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Contatemplater
After=syslog.target network.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/java/amazon-corretto-8.275.01.1-linux-x64
Environment=CATALINA_PID=/srv/template/tomcat/tomcat.pid
Environment=CATALINA_HOME=/srv/template/tomcat
Environment=CATALINA_BASE=/srv/template/tomcat
Environment='CATALINA_AppsS=-Xms1024M -Xmx2650M -server'
Environment='JAVA_AppsS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:+CMSParallelRemarkEnabled  -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=50 -XX:+ScavengeBeforeFullGC -XX:+CMSScavengeBeforeRemark'
ExecStart=/srv/template/tomcat/bin/startup.sh
Environment='ANT_HOME=/usr/share/apache-ant-1.10.1'
ExecStop=/srv/template/tomcat/bin/shutdown.sh
User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF

# Dar permisos de ejecución al servicio
chmod 644 /etc/systemd/system/tomcat.service

# Instalar LibreOffice (si es necesario)
apt install libreoffice -y

# Copiar herramienta JAR de Amazon Corretto a la biblioteca de Tomcat
cp /usr/java/amazon-corretto-8.275.01.1-linux-x64/lib/tools.jar /srv/template/tomcat/lib/
chown tomcat:tomcat /srv/template/tomcat/lib/tools.jar
chown tomcat:tomcat /srv/template/ -R

# Reiniciar el servicio
systemctl daemon-reload
systemctl start tomcat
clear
echo "Instalacion del Artefacto APIA"
sleep 1
cd /home/repo_apia_cifrado/
mv Apia.xml /srv/template/tomcat/conf/Catalina/localhost/
tar -xf statum.tar.gz -C /srv/template/
clear
echo "Dar permisos tomcat"
chown tomcat:tomcat /srv/template/ -R
systemctl stop tomcat
systemctl start tomcat; tail -f /srv/template/tomcat/logs/catalina.out
