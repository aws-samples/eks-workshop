---
title: "Install tools"
date: 2021-06-15T00:00:00-00:00
weight: 30
---

{{% notice info %}}
Wait for the CloudFormation template creation to be completed and successfull.
{{% /notice %}}

TODO:
might not need this clone step


Clone the workshop repo for post deployment steps:

```bash
git clone https://github.com/aws-samples/sql-based-etl-on-amazon-eks.git
cd sql-based-etl-on-amazon-eks
```

```bash
export stack_name="${1:-SparkOnEKS}"

echo "========================================================================="
echo "  Make sure your CloudFormation stack name $stack_name is correct. "
echo "  If you use a different name, rerun the script with a parameter:"
echo "      ./deployment/post-deployment.sh <stack_name> "
echo "========================================================================="

# 1. install k8s command tools 
echo -e "\ninstall kubectl tool..."
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x kubectl
mkdir -p $HOME/bin && mv kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin

echo "================================================================================================"
echo " Installing argoCLI tool on Linux ..."
echo " Check out https://github.com/argoproj/argo-workflows/releases for other OS type installation."
echo "================================================================================================"
VERSION=v3.0.2
sudo curl -sLO https://github.com/argoproj/argo-workflows/releases/download/${VERSION}/argo-linux-amd64.gz && gunzip argo-linux-amd64.gz
chmod +x argo-linux-amd64 && sudo mv ./argo-linux-amd64 /usr/local/bin/argo
argo version --short

# 2. connect to the EKS newly created
echo `aws cloudformation describe-stacks --stack-name $stack_name --query "Stacks[0].Outputs[?starts_with(OutputKey,'eksclusterEKSConfig')].OutputValue" --output text` | bash
echo -e "\ntest EKS connection..."
kubectl get svc

# 3. get Jupyter Hub login
LOGIN_URI=$(aws cloudformation describe-stacks --stack-name $stack_name \
--query "Stacks[0].Outputs[?OutputKey=='JUPYTERURL'].OutputValue" --output text)
SEC_ID=$(aws secretsmanager list-secrets --query "SecretList[?not_null(Tags[?Value=='$stack_name'])].Name" --output text)
LOGIN=$(aws secretsmanager get-secret-value --secret-id $SEC_ID --query SecretString --output text)
echo -e "\n=============================== JupyterHub Login =============================================="
echo -e "\nJUPYTER_URL: $LOGIN_URI"
echo "LOGIN: $LOGIN" 
echo "================================================================================================"

```
