#!/bin/bash
# VS Code Tunnel Startup Script
# This script handles the GitHub device authentication flow and tunnel persistence
set -e

export HOME=/home/vscode

# Set default tunnel name if not provided
TUNNEL_NAME="${TUNNEL_NAME:-my-tunnel}"

# Ensure mounted directories exist
mkdir -p /root/.vscode-cli /root/.vscode-server

echo "🚀 Starting VS Code Tunnel $TUNNEL_NAME..."

# Check if we already have a valid authentication token
# The token is stored in /root/.vscode-cli/tunnels/cli/session.json after successful login
if [ -f "/root/.vscode-cli/tunnels/cli/session.json" ]; then
    echo "✅ Existing VS Code tunnel authentication found."
    echo "🚀 Starting tunnel service..."
    code tunnel --accept-server-license-terms --name "$TUNNEL_NAME"
else
    echo "🔐 No existing authentication found."
    echo "📋 Starting GitHub device login flow..."
    echo ""
    echo "******************************************************************"
    echo "ACTION REQUIRED:"
    echo "1. Visit https://github.com/login/device"
    echo "2. Enter the code that appears below"
    echo "3. Authorize Visual Studio Code"
    echo "******************************************************************"
    echo ""
    
    # Start the tunnel - this will display the device code and wait for authentication
    # The authentication token will be saved to ~/.vscode-cli/tunnels/cli/session.json
    code tunnel --accept-server-license-terms --name "$TUNNEL_NAME"
fi
