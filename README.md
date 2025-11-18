# Install Grafana

A composition action that fetches a Grafana installation script from GitHub and executes it on a remote server via SSH. This action installs Grafana OSS on Debian/Ubuntu systems.

## Overview

This action performs two steps:
1. **Fetch Script**: Downloads the Grafana installation script from a GitHub repository using `http-get-wasm`
2. **Execute Script**: Runs the installation script on a remote server via SSH

## Inputs

The action expects the following inputs:

| Input | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `script_url` | string | No | `https://raw.githubusercontent.com/tgirotto/install-grafana/refs/heads/main/install-grafana.sh` | URL to the Grafana installation script |
| `privateKey` | string | Yes | - | SSH private key for authentication (OpenSSH format) |
| `user` | string | Yes | - | SSH username (e.g., `ubuntu`, `root`) |
| `host` | string | Yes | - | SSH host (IP address or hostname) |

## Usage

### Basic Example

```json
{
  "script_url": "https://raw.githubusercontent.com/tgirotto/install-grafana/refs/heads/main/install-grafana.sh",
  "privateKey": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----",
  "user": "root",
  "host": "1.2.3.4"
}
```

### Using Default Script URL

If you want to use the default script URL, you can omit the `script_url` parameter:

```json
{
  "privateKey": "-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----",
  "user": "ubuntu",
  "host": "192.168.1.100"
}
```

## Outputs

The action provides two outputs:

1. **`script_content`**: The full content of the Grafana installation script that was fetched
2. **`execution_result`**: The stdout output from the SSH execution, containing the installation progress and status

## Installation Process

The installation script performs the following steps:

1. **Updates package lists** with retry logic (up to 10 attempts) to handle apt lock issues
2. **Installs dependencies**: `adduser`, `libfontconfig1`, `wget`, `musl`, `ca-certificates`, `gnupg`, `lsb-release`
3. **Adds Grafana's official repository** using the modern GPG keyring method
4. **Installs Grafana OSS** non-interactively
5. **Starts and enables** the Grafana service
6. **Verifies installation** by checking the service status

## Grafana Access

After successful installation:

- **URL**: `http://<host>:3000`
- **Default credentials**: 
  - Username: `admin`
  - Password: `admin`

⚠️ **Security Note**: Change the default password immediately after first login.

## Requirements

- **Target System**: Debian or Ubuntu-based Linux distribution
- **Privileges**: Root or sudo access on the target server
- **Network**: Internet access on the target server to download packages
- **SSH Access**: Valid SSH credentials with appropriate permissions

## Error Handling

The installation script includes robust error handling:

- **Retry Logic**: All apt commands are retried up to 10 times with 5-second delays to handle package manager locks
- **Non-interactive Mode**: Uses `DEBIAN_FRONTEND=noninteractive` to prevent prompts
- **Service Verification**: Checks service status after installation to confirm success

## Composition Structure

This action is a composition that orchestrates two sub-actions:

1. **`fetch_script`**: Uses `starthubhq/http-get-wasm:0.0.16` to fetch the script
2. **`execute_script`**: Uses `starthubhq/ssh:0.0.1` to execute the script remotely

## Permissions

The action requires network permissions for:
- `http` - To fetch the installation script
- `https` - To fetch the installation script and Grafana packages

## Notes

- The script installs **Grafana OSS** (Open Source Software) from the official Grafana repository
- The installation is idempotent - running it multiple times is safe
- The script handles apt lock contention automatically with retry logic
- Grafana service is automatically started and enabled to run on boot

