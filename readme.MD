# Ingress Controller

REGION_CODE=us-east-1
CLUSTER_NAME=expense
ACCOUNT_ID=897729141306


### Permissions

* OIDC provider
```
eksctl utils associate-iam-oidc-provider \
    --region $REGION_CODE \
    --cluster $CLUSTER_NAME \
    --approve
```

* IAM Policy
```
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.12.0/docs/install/iam_policy.json

```



* CRETAE IAM Role

```
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

```


* if it says already policy exist then delete it and recreate it  delete command is 
```
aws iam delete-policy --policy-arn arn:aws:iam::897729141306:policy/AWSLoadBalancerControllerIAMPolicy
```

* Provider access to EKS through IAM Policy[ ACCOUNT_ID=897729141306REGION_CODE=us-east-1, CLUSTER_NAME=expense ]
```
eksctl create iamserviceaccount \
--cluster=$CLUSTER_NAME \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::$ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region $REGION_CODE \
--approve
```


### Install Drivers

* Add the EKS chart repo to Helm
```
helm repo add eks https://aws.github.io/eks-charts
```

* Install AWS LoadBalancer Controller

```
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$CLUSTER_NAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
```
* or upgrade helm 
```
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=expense \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

```