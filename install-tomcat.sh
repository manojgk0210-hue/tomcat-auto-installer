#!/bin/bash

set -e

echo "================================================="
echo "      Apache Tomcat 10.1.57 Installation"
echo "================================================="

# Ask for Tomcat Manager credentials
read -p "Enter Tomcat Username: " USERNAME
read -s -p "Enter Tomcat Password: " PASSWORD
echo

echo
echo "Updating packages..."
sudo apt update -y

echo
echo "Installing Java..."
sudo apt install openjdk-21-jdk wget -y

echo
echo "Java Version"
java -version

echo
echo "Downloading Tomcat..."

cd /opt

sudo rm -rf tomcat
sudo rm -f apache-tomcat-10.1.57.tar.gz

sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.57/bin/apache-tomcat-10.1.57.tar.gz

sudo tar -xzf apache-tomcat-10.1.57.tar.gz

sudo mv apache-tomcat-10.1.57 tomcat

sudo chmod +x /opt/tomcat/bin/*.sh

sudo chown -R ubuntu:ubuntu /opt/tomcat

echo
echo "Configuring Tomcat Manager..."

CONTEXT_FILE="/opt/tomcat/webapps/manager/META-INF/context.xml"

sudo cp "$CONTEXT_FILE" "${CONTEXT_FILE}.bak"

sudo sed -i '/<Valve/,/\/>/d' "$CONTEXT_FILE"

echo
echo "Creating Tomcat User..."

TOMCAT_USERS="/opt/tomcat/conf/tomcat-users.xml"

sudo cp "$TOMCAT_USERS" "${TOMCAT_USERS}.bak"

grep -q 'rolename="manager-gui"' "$TOMCAT_USERS" || \
sudo sed -i '/<\/tomcat-users>/i\
<role rolename="manager-gui"/>' "$TOMCAT_USERS"

grep -q 'rolename="admin-gui"' "$TOMCAT_USERS" || \
sudo sed -i '/<\/tomcat-users>/i\
<role rolename="admin-gui"/>' "$TOMCAT_USERS"

sudo sed -i "/<\/tomcat-users>/i\\
<user username=\"$USERNAME\" password=\"$PASSWORD\" roles=\"manager-gui,admin-gui\"/>" "$TOMCAT_USERS"

echo
echo "Creating Tomcat Service..."

sudo bash -c 'cat > /etc/systemd/system/tomcat.service << "EOF"
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
EOF'

echo
echo "Reloading systemd..."

sudo systemctl daemon-reload

echo
echo "Enabling Tomcat..."

sudo systemctl enable tomcat

echo
echo "Starting Tomcat..."

sudo systemctl restart tomcat

echo
echo "Waiting for Tomcat to start..."

sleep 10

echo
echo "Checking Tomcat Status..."

if sudo systemctl is-active --quiet tomcat
then
    echo "========================================"
    echo " Tomcat Started Successfully"
    echo "========================================"
else
    echo "Tomcat failed to start."
    sudo systemctl status tomcat --no-pager
    exit 1
fi

echo
echo "Tomcat URL"
echo "http://<EC2-PUBLIC-IP>:8080"

echo
echo "Tomcat Manager"
echo "http://<EC2-PUBLIC-IP>:8080/manager/html"

echo
echo "Username : $USERNAME"
echo "Password : $PASSWORD"

echo
echo "Useful Commands"

echo "sudo systemctl start tomcat"
echo "sudo systemctl stop tomcat"
echo "sudo systemctl restart tomcat"
echo "sudo systemctl status tomcat"
echo "sudo journalctl -u tomcat -f"
