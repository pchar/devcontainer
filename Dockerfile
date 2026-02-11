
FROM ubuntu:22.04

ARG HELM_VERSION=3.14.4
ARG HELMFILE_VERSION=0.164.0
ARG KUBECTL_VERSION=1.30.0

# Validation tools versions (pin for reproducibility)
ARG KUBECONFORM_VERSION=0.6.6
ARG KUBE_LINTER_VERSION=0.7.1

ENV DEBIAN_FRONTEND=noninteractive
ENV CONTAINER_VERSION="1.0.0"
# Base packages + yamllint
# - python3 + pip are used to install yamllint reliably on Ubuntu 22.04
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
    python3 \
    mlocate \
    traceroute \
    netcat \
    vim \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

# ---- yamllint ----
RUN pip3 install --no-cache-dir yamllint
RUN pip3 install --upgrade pip   setuptools
RUN pip3 install --upgrade  setuptools pre-commit \
    flake8 isort black yapf mypy autopep8 pyyaml ruamel.yaml
# ---- pre-commit  ----
# ---- kubectl ----
RUN curl -fsSL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# ---- helm ----
RUN curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
 | tar -xz \
 && mv linux-amd64/helm /usr/local/bin/helm \
 && rm -rf linux-amd64

# ---- helmfile ----
RUN curl -fsSL https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz \
 | tar -xz \
 && mv helmfile /usr/local/bin/helmfile

 
# ---- argo-cd cli  ----
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 \ 
&& chmod +x /usr/local/bin/argocd


# ---- kubeconform (schema validation) ----
RUN curl -fsSL \
      https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz \
 | tar -xz \
 && mv kubeconform /usr/local/bin/kubeconform \
 && chmod +x /usr/local/bin/kubeconform

# ---- kube-linter (best practices / security) ----
RUN curl -fsSL \
      https://github.com/stackrox/kube-linter/releases/download/v${KUBE_LINTER_VERSION}/kube-linter-linux.tar.gz \
 | tar -xz \
 && mv kube-linter /usr/local/bin/kube-linter \
 && chmod +x /usr/local/bin/kube-linter

# ---- quick sanity check (fail build early if something is wrong) ----
RUN helm version \
 && helmfile --version \
 && kubectl version --client \
 && kubeconform -v \
 && kube-linter version \
 && yamllint --version \
 && git --version

# ---- helper script: validate chart/templates quickly ----
RUN cat > /usr/local/bin/validate-helm <<'EOF' \
 && chmod +x /usr/local/bin/validate-helm
#!/usr/bin/env bash
set -euo pipefail

CHART_DIR="${1:-.}"
K8S_VERSION="${K8S_VERSION:-1.29.0}"

echo "==> Helm lint (${CHART_DIR})"
helm lint "${CHART_DIR}"

echo "==> Render templates and validate schema with kubeconform (k8s=${K8S_VERSION})"
helm template "${CHART_DIR}" \
 | kubeconform -strict -summary -kubernetes-version "${K8S_VERSION}"

echo "==> kube-linter (best practices)"
# kube-linter expects YAML files. If you want to lint rendered manifests instead,
# you can redirect helm template output to a file and lint that.
kube-linter lint "${CHART_DIR}" || true

echo "==> yamllint"
yamllint -s "${CHART_DIR}"

echo "✅ Validation complete"
EOF

WORKDIR /workspace
CMD ["sleep", "infinity"]
