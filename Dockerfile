# ------------------------------------------------------------
# Dev Containers compatible Helm / Helmfile image
# ------------------------------------------------------------
FROM alpine:3.19

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Install Helm
ARG HELM_VERSION=3.14.0
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && rm -rf /tmp/linux-amd64 \
    && helm version

# Install Helmfile
ARG HELMFILE_VERSION=0.162.0
RUN curl -fsSL https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz | tar -xz -C /tmp \
    && mv /tmp/helmfile /usr/local/bin/helmfile \
    && chmod +x /usr/local/bin/helmfile \
    && helmfile version

# Install kubectl (required by Helmfile)
ARG KUBECTL_VERSION=1.29.1
RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client

# Set default shell to bash
ENV SHELL=/bin/bash

# Create a non-root user for Dev Containers
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -D -u $USER_UID -G $USERNAME $USERNAME \
    && mkdir -p /home/$USERNAME/.kube \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["/bin/bash"]
