#!/bin/bash
set -e

# Function to retry apt commands with lock handling
retry_apt() {
    local max_attempts=10
    local delay=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts: $*"
        
        if sudo "$@"; then
            echo "Command succeeded on attempt $attempt"
            return 0
        else
            echo "Command failed on attempt $attempt"
            if [ $attempt -lt $max_attempts ]; then
                echo "Waiting $delay seconds before retry..."
                sleep $delay
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    echo "Command failed after $max_attempts attempts"
    return 1
}

# Update package list with retry
retry_apt apt-get update -y

# Install dependencies including musl
retry_apt apt-get install -y adduser libfontconfig1 wget musl ca-certificates gnupg lsb-release

# Add Grafana's official repository (modern method)
# Remove existing keyring if it exists to avoid overwrite prompt
sudo rm -f /usr/share/keyrings/grafana-archive-keyring.gpg
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package list again
retry_apt apt-get update -y

# Install Grafana non-interactively
retry_apt DEBIAN_FRONTEND=noninteractive apt-get install -y grafana

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Check status
sudo systemctl status grafana-server --no-pager

echo "Grafana installed successfully!"
echo "Access Grafana at: http://localhost:3000"
echo "Default credentials: admin/admin"