# 🐳 Docker MySQL Backup Tool

A powerful, flexible tool for automating MySQL database backups from Docker containers across multiple servers.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Bash](https://img.shields.io/badge/language-Bash-green.svg)

## ✨ Features

- **Multi-server support**: Configure and back up databases from multiple servers
- **Zero dependencies**: Just Bash and SSH (plus optional sshpass for passwordless operation)
- **Secure**: Support for password or SSH key authentication
- **Container-aware**: Works directly with Docker containers
- **Customizable**: Flexible configuration for each server

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/developerabdan/mysql-docker-backup-automation.git
cd mysql-docker-backup-automation
chmod +x backup.sh
```

### 2. Create your server configurations

```bash
# Create configs directory if it doesn't exist
mkdir -p configs

# Copy the example config file and edit for your server
cp config.example.cfg configs/myserver.cfg
nano configs/myserver.cfg  # Edit with your details
```

### 3. Ensure passwordless SSH access (Option 1: SSH keys)

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096

# Copy your public key to the server
ssh-copy-id username@your-server.com
```

### 4. For password-based authentication (Option 2: sshpass)

```bash
# macOS (using Homebrew)
brew install hudochenkov/sshpass/sshpass

# Ubuntu/Debian
sudo apt-get install sshpass

# CentOS/RHEL
sudo yum install sshpass
```

## 📋 Usage

### Basic Usage

```bash
# List available server configurations
./backup.sh  

# Backup a specific server
./backup.sh myserver

# Create a scheduled backup (cron job) - backs up daily at 2:00 AM
crontab -e
0 2 * * * /path/to/mysql-docker-backup-automation/backup.sh myserver
```

### Backup File Location

Backups are stored inside the Docker container at the path specified in your configuration:

```
/var/lib/mysql/dbname_YYYYMMDD_HHMMSS.sql
```

You can modify the backup script to download the files locally if needed.

### Adding More Servers

Simply add new configuration files to the `configs/` directory:

```bash
cp config.example.cfg configs/another-server.cfg
nano configs/another-server.cfg  # Edit with the new server details
```

## 🔧 Troubleshooting

- **SSH Connection Issues**: Ensure your SSH credentials are correct and that SSH access is permitted
- **Container Not Found**: Verify the container name in your config and that the container is running
- **Backup Permission Errors**: Check that the MySQL user has permissions to execute dumps

## 📃 License

This project is licensed under the MIT License - see the LICENSE file for details

## ⭐ Support

If you find this tool useful, please give it a star on GitHub! Your support helps maintain and improve the project.

```
⭐ Star this repo if you found it helpful! ⭐
```

## 👤 Author

@abdansyakuro.id