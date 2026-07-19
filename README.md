# Apache Tomcat Auto Installer

This repository contains a simple Bash script to automatically install and configure Apache Tomcat on Ubuntu.

## What This Script Does

- Installs **OpenJDK 21**
- Downloads and installs **Apache Tomcat 10.1.57**
- Configures the Tomcat Manager application
- Creates a Tomcat Manager user
- Creates a Tomcat systemd service
- Starts and enables the Tomcat service

## Prerequisites

- Ubuntu 22.04 or later
- Sudo privileges
- Internet connection

## How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/tomcat-auto-installer.git
```

### 2. Go to the Project Directory

```bash
cd tomcat-auto-installer
```

### 3. Open the Script (Optional)

```bash
sudo nano install-tomcat.sh
```

### 4. Make the Script Executable

```bash
sudo chmod +x install-tomcat.sh
```

### 5. Run the Script

```bash
sudo ./install-tomcat.sh
```

### 6. Enter the Tomcat Credentials

The script will ask for:

```text
Enter Tomcat Username:
Enter Tomcat Password:
```

Use these credentials to log in to the Tomcat Manager.

## Installed Versions

| Software | Version |
|----------|---------|
| Java | OpenJDK 21 |
| Apache Tomcat | 10.1.57 |

## Access Tomcat

### Tomcat Home

```
http://<EC2-PUBLIC-IP>:8080
```

### Tomcat Manager

```
http://<EC2-PUBLIC-IP>:8080/manager/html
```

Log in using the username and password you entered during the installation.

## Useful Commands

Start Tomcat

```bash
sudo systemctl start tomcat
```

Stop Tomcat

```bash
sudo systemctl stop tomcat
```

Restart Tomcat

```bash
sudo systemctl restart tomcat
```

Check Status

```bash
sudo systemctl status tomcat
```

View Logs

```bash
sudo journalctl -u tomcat -f
```
