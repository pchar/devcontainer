
# ------------------------------------------------------------
# Dev Containers compatible Helm / Helmfile image
# ------------------------------------------------------------
FROM alpine:3.19

# ------------------------------------------------------------
# Versions (easy to pin / upgrade)
# ------------------------------------------------------------
ARG HELM_VERSION=3.14.4
ARG HELMFILE_VERSION=0.164.0
ARG KUBECTL_VERSION=1.30.0

# ------------------------------------------------------------
# Core system dependencies
# REQUIRED for VS Code Dev Containers
# ------------------------------------------------------------
RUN apk add --no-cache \
    bash \
    git \
    curl \
    ca-certificates \
    tar \
    gzip \
    libstdc++ \
    libgcc \
    openssh \
    coreutils

# ------------------------------------------------------------
# Install kubectl
# ------------------------------------------------------------
RUN curl -fsSL \
      https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
      -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# ------------------------------------------------------------
# Install Helm
# ------------------------------------------------------------
RUN curl -fsSL \
      https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 | tar -xz \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -rf linux-amd64

# ------------------------------------------------------------
# Install Helmfile
# ------------------------------------------------------------
RUN curl -fsSL \
      https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
 | tar -xz \
 && mv helmfile /usr/local/bin/helmfile

# ------------------------------------------------------------
# Verify installs (fails build early if something is wrong)
# ------------------------------------------------------------
RUN helm version \
 && helmfile --version \
 && kubectl version --client \
 && git --version

# ------------------------------------------------------------
# Workspace for Dev Containers
# ------------------------------------------------------------
WORKDIR /workspace

# Keep container alive when used interactively
CMD ["sleep", "infinity"]
