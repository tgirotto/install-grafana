#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install dependencies including musl
sudo apt-get install -y adduser libfontconfig1 wget musl ca-certificates gnupg lsb-release

# Add Grafana's official repository (modern method)
wget -q -O - https://packages.grafana.com/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/grafana-archive-keyring.gpg] https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package list again
sudo apt-get update

# Install Grafana
sudo apt-get install -y grafana

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Check status
sudo systemctl status grafana-server

echo "Grafana installed successfully!"
echo "Access Grafana at: http://localhost:3000"
echo "Default credentials: admin/admin"