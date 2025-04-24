#!/usr/bin/env pwsh
# @abdansyakuro.id
# Windows Automated database backup script (PowerShell version)

# Check if a server name was provided
param(
    [string]$ServerName
)

if (-not $ServerName) {
    Write-Host "Usage: .\backup.ps1 <server_name>"
    Write-Host "Available servers:"
    Get-ChildItem -Path "$PSScriptRoot\configs" -Filter "*.cfg" | ForEach-Object { $_.BaseName }
    exit 1
}

$CONFIG_PATH = "$PSScriptRoot\configs\$ServerName.cfg"

# Check if config file exists
if (-not (Test-Path $CONFIG_PATH)) {
    Write-Host "Error: Configuration file not found for server: $ServerName"
    Write-Host "Available servers:"
    Get-ChildItem -Path "$PSScriptRoot\configs" -Filter "*.cfg" | ForEach-Object { $_.BaseName }
    exit 1
}

# Load config for specific server
Write-Host "Loading config for server: $ServerName"
# Source the config file
$configContent = Get-Content -Path $CONFIG_PATH -Raw
$scriptBlock = [ScriptBlock]::Create($configContent)
. $scriptBlock

Write-Host "Using Docker container: $CONTAINER_NAME"

# For local Docker operations
if ($DOCKER_LOCAL -eq "true") {
    Write-Host "Executing local Docker backup..."
    
    # Timestamp for filename
    $timestamp = Get-Date -Format $DATE_FORMAT
    $backup_filename = "${BACKUP_PREFIX}_${timestamp}.sql"
    
    Write-Host "Finding container ID for container name $CONTAINER_NAME..."
    $container_id = docker ps --filter "name=$CONTAINER_NAME" --format "{{.ID}}" | Select-Object -First 1
    
    if (-not $container_id) {
        Write-Host "Error: No running container found for container name $CONTAINER_NAME"
        exit 1
    }
    
    Write-Host "Container found: $container_id"
    Write-Host "Backing up database from container $container_id..."
    Write-Host "Executing mysqldump inside container at ${MYSQL_PATH}/${backup_filename}"
    
    # Run mysqldump inside container; write backup into container filesystem
    docker exec $container_id sh -c "mysqldump -u${DB_USER} -p${DB_PASS} ${DB_NAME} --no-tablespaces > ${MYSQL_PATH}/${backup_filename}"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Backup successful: ${MYSQL_PATH}/${backup_filename} in container"
        
        # If local backup saving is enabled
        if ($SAVE_LOCAL -eq "true") {
            # Create backup directory if it doesn't exist
            if (-not (Test-Path $BACKUP_DIR)) {
                New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
            }
            
            Write-Host "Copying backup from container to local path: $BACKUP_DIR\$backup_filename"
            docker cp "${container_id}:${MYSQL_PATH}/${backup_filename}" "$BACKUP_DIR\$backup_filename"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Local backup saved successfully"
            } else {
                Write-Host "Failed to save local backup"
            }
        }
    } else {
        Write-Host "Backup failed"
        exit 1
    }
} 
# For remote Docker operations via SSH
else {
    Write-Host "Executing remote Docker backup via SSH..."
    
    # Timestamp for filename
    $timestamp = Get-Date -Format $DATE_FORMAT
    $backup_filename = "${BACKUP_PREFIX}_${timestamp}.sql"
    
    # Setup SSH command based on authentication method
    if ($SSH_KEY -and (Test-Path $SSH_KEY)) {
        Write-Host "Using SSH key: $SSH_KEY"
        $ssh_options = "-i `"$SSH_KEY`" -o StrictHostKeyChecking=no -p $SSH_PORT"
    } else {
        Write-Host "Using password authentication (will prompt for password)"
        $ssh_options = "-p $SSH_PORT"
    }
    
    # Find the MySQL container ID by container name
    Write-Host "Finding container ID for container name $CONTAINER_NAME..."
    $ssh_cmd = "ssh $ssh_options $SSH_USER@$SSH_HOST `"docker ps --filter name=$CONTAINER_NAME --format '{{.ID}}' | head -n1`""
    Write-Host "Executing: $ssh_cmd"
    $container_id = Invoke-Expression $ssh_cmd
    
    if (-not $container_id) {
        Write-Host "Error: No running container found for container name $CONTAINER_NAME"
        exit 1
    }
    
    Write-Host "Container found: $container_id"
    Write-Host "Backing up database from container $container_id..."
    Write-Host "Executing mysqldump inside container at ${MYSQL_PATH}/${backup_filename}"
    
    # Run mysqldump inside container via SSH; write backup into container filesystem
    $backup_cmd = "ssh $ssh_options $SSH_USER@$SSH_HOST `"docker exec $container_id sh -c 'mysqldump -u$DB_USER -p$DB_PASS $DB_NAME --no-tablespaces > $MYSQL_PATH/$backup_filename'`""
    Write-Host "Executing: $backup_cmd"
    Invoke-Expression $backup_cmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Backup successful: ${MYSQL_PATH}/${backup_filename} in container"
    } else {
        Write-Host "Backup failed"
        exit 1
    }
} 