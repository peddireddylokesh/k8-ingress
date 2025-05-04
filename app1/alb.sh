#!/bin/bash

set -e

echo "➡️ Installing eksctl..."
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

echo "➡️ Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
sudo ./aws/install
aws --version

echo "➡️ Installing kubectl..."
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/latest/2023-11-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --client

echo "➡️ Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

echo "✅ All tools installed."

echo "➡️ Running install-alb-controller.sh..."
sudo bash install-alb-controller.sh
