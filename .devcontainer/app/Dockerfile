FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install Copilot CLI
RUN curl -fsSL https://gh.io/copilot-install | bash

# Install D2
RUN D2_VERSION="v0.7.1" && \
    curl -fsSL "https://github.com/terrastruct/d2/releases/download/${D2_VERSION}/d2-${D2_VERSION}-linux-amd64.tar.gz" -o /tmp/d2.tar.gz && \
    tar -xzf /tmp/d2.tar.gz -C /tmp && \
    mv "/tmp/d2-${D2_VERSION}/bin/d2" /usr/local/bin/d2 && \
    chmod +x /usr/local/bin/d2 && \
    rm -rf /tmp/d2*

# Verify installations
RUN d2 --version
