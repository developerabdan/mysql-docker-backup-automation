# 🐳 Docker MySQL Backup Tool

A powerful, flexible tool for automating MySQL database backups from Docker containers across multiple servers.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Bash](https://img.shields.io/badge/language-Bash-green.svg)
![PowerShell](https://img.shields.io/badge/language-PowerShell-blue.svg)
![Cross-Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS%20|%20Windows-lightgrey.svg)

## ✨ Features

- **Multi-server support**: Configure and back up databases from multiple servers
- **Zero dependencies**: Just Bash/PowerShell and SSH (plus optional sshpass for passwordless operation)
- **Secure**: Support for password or SSH key authentication
- **Container-aware**: Works directly with Docker containers
- **Customizable**: Flexible configuration for each server
- **Cross-Platform**: Works on Linux, macOS, and Windows

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/developerabdan/mysql-docker-backup-automation.git
cd mysql-docker-backup-automation
```

### 2. Set execution permissions (Linux/macOS)

```bash
chmod +x backup.sh
```

### 3. Create your server configurations

```bash
# Create configs directory if it doesn't exist
mkdir -p configs

# Copy the example config file and edit for your server
# For Linux/macOS:
cp config.example.cfg configs/myserver.cfg
nano configs/myserver.cfg  # Edit with your details

# For Windows:
copy config.windows.example.cfg configs\myserver.cfg
notepad configs\myserver.cfg  # Edit with your details
```

### 4. Ensure passwordless SSH access (Option 1: SSH keys)

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096

# Copy your public key to the server
ssh-copy-id username@your-server.com
```

### 5. For password-based authentication (Option 2: sshpass)

```bash
# macOS (using Homebrew)
brew install hudochenkov/sshpass/sshpass

# Ubuntu/Debian
sudo apt-get install sshpass

# CentOS/RHEL
sudo yum install sshpass

# Windows
# For Windows, password-based SSH is supported natively through PowerShell
```

## 📋 Usage

### Basic Usage

#### Linux/macOS

```bash
# List available server configurations
./backup.sh  

# Backup a specific server
./backup.sh myserver
```

#### Windows

```powershell
# Using PowerShell
# List available server configurations
.\backup.ps1

# Backup a specific server
.\backup.ps1 myserver

# Using the batch file wrapper
# List available server configurations
backup.bat

# Backup a specific server
backup.bat myserver
```

### Local Docker Operations

For local Docker operations, set `DOCKER_LOCAL="true"` in your configuration file (default in Windows configuration).

### Scheduled Backups

#### Linux/macOS (cron)

```bash
# Create a scheduled backup (cron job) - backs up daily at 2:00 AM
crontab -e
0 2 * * * /path/to/mysql-docker-backup-automation/backup.sh myserver
```

#### Windows (Task Scheduler)

1. Open Task Scheduler
2. Create a new task
3. Set the trigger to daily at your preferred time
4. For the action, set Program/script to:
   - PowerShell: `powershell.exe` with arguments: `-ExecutionPolicy Bypass -File "C:\path\to\mysql-docker-backup-automation\backup.ps1" myserver`
   - Batch file: `C:\path\to\mysql-docker-backup-automation\backup.bat` with arguments: `myserver`

### Backup File Location

Backups are stored inside the Docker container at the path specified in your configuration:

```
/var/lib/mysql/dbname_YYYYMMDD_HHMMSS.sql
```

With the Windows PowerShell script, you can also save a local copy by setting `$SAVE_LOCAL = "true"` in your configuration.

### Adding More Servers

Simply add new configuration files to the `configs/` directory:

```bash
# Linux/macOS
cp config.example.cfg configs/another-server.cfg
nano configs/another-server.cfg  # Edit with the new server details

# Windows
copy config.windows.example.cfg configs\another-server.cfg
notepad configs\another-server.cfg  # Edit with the new server details
```

## 🔧 Troubleshooting

- **SSH Connection Issues**: Ensure your SSH credentials are correct and that SSH access is permitted
- **Container Not Found**: Verify the container name in your config and that the container is running
- **Backup Permission Errors**: Check that the MySQL user has permissions to execute dumps
- **Windows PowerShell Execution Policy**: You may need to set the execution policy to allow running scripts with `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

## 📃 License

This project is licensed under the MIT License - see the LICENSE file for details

## ⭐ Support

If you find this tool useful, please give it a star on GitHub! Your support helps maintain and improve the project.

```
⭐ Star this repo if you found it helpful! ⭐
```

## 👤 Author

- @abdansyakuro.id
- purwa.theskinnyrat.com
