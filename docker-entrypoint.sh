#!/bin/bash

# Root-level entrypoint: fix permissions, then drop to non-root user

echo "🔧 Setting up permissions for VS Code tunnel..."

# Fix permissions on mounted directories (run as root)
chown -R vscode:vscode /home/vscode/.vscode-cli 2>/dev/null || true
chown -R vscode:vscode /home/vscode/.vscode-server 2>/dev/null || true
chown -R vscode:vscode /home/vscode/projects 2>/dev/null || true

# Ensure projects directory is writable in container
chmod 777 /home/vscode/projects 2>/dev/null || true

echo "✅ Permissions fixed. Starting VS Code tunnel as non-root user..."

# Switch to non-root user and run the main entrypoint
exec sudo -u vscode /home/vscode/entrypoint.sh
