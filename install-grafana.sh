#!/bin/bash
set -e

# Update package list
sudo apt-get update

# Install dependencies
sudo apt-get install -y adduser libfontconfig1 wget

# Get the latest Grafana version
GRAFANA_VERSION="10.4.0"
wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb

# Install Grafana
sudo dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Check status
sudo systemctl status grafana-server

echo "Grafana installed successfully!"
echo "Access Grafana at: http://localhost:3000"
echo "Default credentials: admin/admin"