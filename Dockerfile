FROM debian:bookworm-slim

# Environment setup for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install essential dependencies:
# - libsecret-1-0: Secure credential storage for GitHub tokens
# - libnss3, libasound2, libxkbfile1: Required for VS Code extensions and UI components
# - ca-certificates, curl: For secure downloads and connections
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libasound2 \
    libnss3 \
    libxkbfile1 \
    libsecret-1-0 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security (UID 1000)
RUN useradd -m -s /bin/bash vscode
USER vscode
WORKDIR /home/vscode

# Download VS Code CLI for ARM64 (M-series Macs)
# Using official VS Code download endpoint - stable Alpine ARM64 build
RUN curl -L "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64" \
    -o vscode_cli.tar.gz \
    && tar -xf vscode_cli.tar.gz -C /home/vscode/ \
    && rm vscode_cli.tar.gz \
    && chmod +x /home/vscode/code

# Create directory structure that VS Code expects
# These will be overwritten by bind mounts, but ensure container works without mounts
RUN mkdir -p /home/vscode/.vscode-cli/tunnels \
    && mkdir -p /home/vscode/.vscode-server

# Add the CLI to PATH so 'code' command works
ENV PATH="/home/vscode:${PATH}"

# Copy and set up the entrypoint script
COPY --chown=vscode:vscode entrypoint.sh /home/vscode/entrypoint.sh
RUN chmod +x /home/vscode/entrypoint.sh

ENTRYPOINT ["/home/vscode/entrypoint.sh"]
