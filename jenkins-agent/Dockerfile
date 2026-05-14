FROM debian:12-slim

ARG TERRAFORM_VERSION=1.10.5
ARG KUBECTL_VERSION=v1.33.10
ARG TALOSCTL_VERSION=v1.12.7
ARG PACKER_VERSION=1.12.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    jq \
    openssh-client \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm -f /tmp/terraform.zip \
    && terraform version

RUN curl -fsSL -o /usr/local/bin/kubectl \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client=true

RUN curl -fsSL -o /usr/local/bin/talosctl \
    "https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-amd64" \
    && chmod +x /usr/local/bin/talosctl

RUN curl -fsSL -o /tmp/packer.zip \
    "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
    && unzip -o /tmp/packer.zip -d /usr/local/bin \
    && rm -f /tmp/packer.zip

RUN useradd -m -s /bin/bash jenkins

USER jenkins
WORKDIR /home/jenkins