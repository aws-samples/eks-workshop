---
title: "Add Workers"
date: 2018-08-07T11:05:19-07:00
weight: 60
draft: true
---

Now that your VPC and Kubernetes control plane are created, you can launch and
configure your worker nodes. We will now use CloudFormation to launch worker
nodes that will connect to the EKS cluster:
```
export SUBNET_IDS=$(aws cloudformation describe-stacks --stack-name "eksworkshop-cf" --query "Stacks[0].Outputs[?OutputKey=='SubnetIds'].OutputValue" --output text)
export SECURITY_GROUP=$(aws cloudformation describe-stacks --stack-name "eksworkshop-cf" --query "Stacks[0].Outputs[?OutputKey=='SecurityGroups'].OutputValue" --output text)
export VPC_ID=$(aws cloudformation describe-stacks --stack-name "eksworkshop-cf" --query "Stacks[0].Outputs[?OutputKey=='VpcId'].OutputValue" --output text)

aws cloudformation create-stack --stack-name "eksworkshop-cf-worker-nodes" \
--template-url "https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml" \
--capabilities CAPABILITY_IAM \
--parameters \
ParameterKey=KeyName,ParameterValue=eksworkshop \
ParameterKey=NodeImageId,ParameterValue=ami-73a6e20b \
ParameterKey=NodeGroupName,ParameterValue=eks-howto-workers \
ParameterKey=ClusterControlPlaneSecurityGroup,ParameterValue=$SECURITY_GROUP \
ParameterKey=VpcId,ParameterValue=$VPC_ID \
ParameterKey=Subnets,ParameterValue=\"$SUBNET_IDS\" \
ParameterKey=ClusterName,ParameterValue=eksworkshop-cf
```
{{% notice info %}}
The creation of the workers will take about 3 minutes.
{{% /notice %}}
This is a script that will let you know when the CloudFormation stack is complete:
```
until [[ `aws cloudformation describe-stacks --stack-name "eksworkshop-cf-worker-nodes" --query "Stacks[0].[StackStatus]" --output text` == "CREATE_COMPLETE" ]]; do  echo "The stack is NOT in a state of CREATE_COMPLETE at `date`";   sleep 30; done && echo "The Stack is built at `date` - Please proceed"
```
