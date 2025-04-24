#!/usr/bin/env bash
# @abdansyakuro.id
# Automated database backup script

# Check if a server name was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <server_name>"
    echo "Available servers:"
    ls -1 "$(dirname "$0")/configs" | sed 's/\.cfg$//'
    exit 1
fi

SERVER_NAME="$1"
CONFIG_PATH="$(dirname "$0")/configs/${SERVER_NAME}.cfg"

# Check if config file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Error: Configuration file not found for server: $SERVER_NAME"
    echo "Available servers:"
    ls -1 "$(dirname "$0")/configs" | sed 's/\.cfg$//'
    exit 1
fi

# Load config for specific server
echo "Loading config for server: $SERVER_NAME"
source "$CONFIG_PATH"
echo "Logging into SSH: $SSH_USER@$SSH_HOST"

# Local backup directory not needed when storing inside container
# mkdir -p "$BACKUP_DIR"

# Timestamp for filename
timestamp=$(date +"$DATE_FORMAT")
backup_filename="${BACKUP_PREFIX}_${timestamp}.sql"

# Setup SSH command for automation
if [ -n "$SSH_KEY" ] && [ -f "$SSH_KEY" ]; then
    echo "Using SSH key: $SSH_KEY"
    SSH_CMD="ssh -i $SSH_KEY -o StrictHostKeyChecking=no -p $SSH_PORT"
elif command -v sshpass >/dev/null 2>&1 && [ -n "$SSH_PASS" ]; then
    echo "Using sshpass for password authentication"
    SSH_CMD="sshpass -p $SSH_PASS ssh -o StrictHostKeyChecking=no -p $SSH_PORT"
else
    echo "Note: Using interactive password prompt (sshpass not installed or no password configured)"
    echo "For non-interactive use, either:"
    echo "1. Install sshpass: brew install hudochenkov/sshpass/sshpass"
    echo "2. Set up SSH key authentication: ssh-copy-id $SSH_USER@$SSH_HOST"
fi

# Find the MySQL container ID by container name
echo "Finding container ID for container name $CONTAINER_NAME..."
container_id=$($SSH_CMD "$SSH_USER@$SSH_HOST" \
    "docker ps --filter name=${CONTAINER_NAME} --format '{{.ID}}' | head -n1")
echo "Container found: $container_id"

if [ -z "$container_id" ]; then
    echo "Error: No running container found for container name $CONTAINER_NAME"
    exit 1
fi

echo "Backing up database from container $container_id..."
echo "Executing mysqldump inside container at ${MYSQL_PATH}/${backup_filename}"
# Run mysqldump inside container; write backup into container filesystem
${SSH_CMD} "$SSH_USER@$SSH_HOST" \
    "docker exec $container_id sh -c 'mysqldump -u${DB_USER} -p${DB_PASS} ${DB_NAME} --no-tablespaces > ${MYSQL_PATH}/${backup_filename}'"

if [ $? -eq 0 ]; then
    echo "Backup successful: ${MYSQL_PATH}/${backup_filename} in container"
else
    echo "Backup failed"
    exit 1
fi