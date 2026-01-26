
FROM ubuntu:22.04

ARG HELM_VERSION=3.14.4
ARG HELMFILE_VERSION=0.164.0
ARG KUBECTL_VERSION=1.30.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    bash \
    tar \
    gzip \
    openssh-client \
    gnupg \
    less \
    iputils-ping \
    net-tools \
 && rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -fsSL \
      https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
      -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# helm
RUN curl -fsSL \
      https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 | tar -xz \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -rf linux-amd64

# helmfile
RUN curl -fsSL \
      https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
 | tar -xz \
 && mv helmfile /usr/local/bin/helmfile

WORKDIR /workspace
CMD ["sleep", "infinity"]
