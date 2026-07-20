#!/bin/bash

set -e

# ==============================
# Tomcat Credentials
# ==============================
USERNAME="admin"
PASSWORD="Admin@123"

exec > /var/log/user-data.log 2>&1

echo "================================================="
echo "      Apache Tomcat 10.1.57 Installation"
echo "================================================="

apt update -y

apt install openjdk-21-jdk wget -y

java -version

cd /opt

rm -rf tomcat
rm -f apache-tomcat-10.1.57.tar.gz

wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.57/bin/apache-tomcat-10.1.57.tar.gz

tar -xzf apache-tomcat-10.1.57.tar.gz

mv apache-tomcat-10.1.57 tomcat

chmod +x /opt/tomcat/bin/*.sh

chown -R ubuntu:ubuntu /opt/tomcat

# Configure Tomcat Manager
CONTEXT_FILE="/opt/tomcat/webapps/manager/META-INF/context.xml"

cp "$CONTEXT_FILE" "${CONTEXT_FILE}.bak"

sed -i '/<Valve/,/\/>/d' "$CONTEXT_FILE"

# Configure Tomcat Users
TOMCAT_USERS="/opt/tomcat/conf/tomcat-users.xml"

cp "$TOMCAT_USERS" "${TOMCAT_USERS}.bak"

grep -q 'rolename="manager-gui"' "$TOMCAT_USERS" || \
sed -i '/<\/tomcat-users>/i\
<role rolename="manager-gui"/>' "$TOMCAT_USERS"

grep -q 'rolename="admin-gui"' "$TOMCAT_USERS" || \
sed -i '/<\/tomcat-users>/i\
<role rolename="admin-gui"/>' "$TOMCAT_USERS"

sed -i "/<\/tomcat-users>/i\\
<user username=\"$USERNAME\" password=\"$PASSWORD\" roles=\"manager-gui,admin-gui\"/>" "$TOMCAT_USERS"

# Create Systemd Service
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking

User=ubuntu
Group=ubuntu

Environment=JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl enable tomcat

systemctl restart tomcat

sleep 10

systemctl status tomcat --no-pager

echo "========================================"
echo " Tomcat Installation Completed"
echo "========================================"
echo "Tomcat URL: http://<EC2-PUBLIC-IP>:8080"
echo "Manager URL: http://<EC2-PUBLIC-IP>:8080/manager/html"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
