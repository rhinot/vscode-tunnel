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

WORKDIR /home/vscode

# Download VS Code CLI for the appropriate architecture
# Only able to use builds available at official VS Code download endpoint
# x86 and arm64 (e.g. M-series Macs) only have alpine version available, where armhf has linux
RUN ARCH="$(uname -m)"; \
    case "$ARCH" in \
        "x86_64") VARIANT="alpine-x64";; \
        "aarch64") VARIANT="alpine-arm64";; \
        "armv7l") VARIANT="linux-armhf";; \
        *) exit 1;; \
    esac && \
    mkdir -p /opt/vscode-cli && \
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=cli-${VARIANT}" \
        -o /opt/vscode-cli/vscode_cli.tar.gz && \
    tar -xf /opt/vscode-cli/vscode_cli.tar.gz -C /opt/vscode-cli && \
    rm /opt/vscode-cli/vscode_cli.tar.gz && \
    chmod +x /opt/vscode-cli/code && \
    ln -s /opt/vscode-cli/code /usr/local/bin/code

# Add the CLI to PATH so 'code' command works
ENV PATH="/opt/vscode-cli:${PATH}"

# Copy and set up the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

