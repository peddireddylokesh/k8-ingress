#!/bin/bash

# Variables
REGION_CODE=us-east-1
CLUSTER_NAME=expense
ACCOUNT_ID=897729141306

echo "➡️ Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider \
    --region $REGION_CODE \
    --cluster $CLUSTER_NAME \
    --approve

echo "➡️ Downloading IAM policy..."
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.12.0/docs/install/iam_policy.json

echo "➡️ Creating IAM policy..."
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json || echo "IAM policy might already exist."

echo "➡️ Creating IAM service account..."
eksctl create iamserviceaccount \
    --cluster=$CLUSTER_NAME \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
    --override-existing-serviceaccounts \
    --region $REGION_CODE \
    --approve

echo "➡️ Installing CRDs..."
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

echo "➡️ Adding Helm repo..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

echo "➡️ Getting VPC ID..."
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION_CODE --query "cluster.resourcesVpcConfig.vpcId" --output text)

echo "➡️ Installing AWS Load Balancer Controller via Helm..."
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set region=$REGION_CODE \
    --set vpcId=$VPC_ID \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller

echo "✅ Done! Now verify:"
echo "kubectl get deployment -n kube-system aws-load-balancer-controller"


