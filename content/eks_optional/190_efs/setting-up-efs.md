---
title: "Setting up the EFS File System"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

When an EFS file system is first created, there is only one root directory at /. We will have to first create a sub-directory under this root within the EFS file system. The EFS Provisioner will create child directories under this sub-directory to back each PersistentVolume it provisions (more on this in the following sections).

In order to do that, you will first launch an EC2 instance of type t2.micro in the EKS cluster VPC using Amazon Linux 2 AMI and allow inbound access to that instance on port 22 so that you may SSH into it. Make sure you are using the latest AMI for your AWS Region.
```
SECURITY_GROUP_NAME="ec2-instance-group"
SECURITY_GROUP_DESC="Allow SSH access to EC2 instance from Everywhere"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "$SECURITY_GROUP_DESC" --vpc-id $VPC_ID | jq --raw-output '.GroupId')
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
```
```
IMAGE_ID=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????.?-x86_64-gp2' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text) 
INSTANCE_ID=$(aws ec2 run-instances \
--image-id $IMAGE_ID \
--count 1 \
--instance-type t2.micro \
--key-name "eksworkshop" \
--security-group-ids $SECURITY_GROUP_ID \
--subnet-id $subnet \
--associate-public-ip-address |  jq --raw-output '.Instances[0].InstanceId')
```

SSH into the EC2 instance by running the following command. You may have wait for a short period before the newly launched instance transitions to a ready state.
```
IP_ADDRESS=$(aws ec2 describe-instances --instance-id $INSTANCE_ID | jq --raw-output '.Reservations[0].Instances[0].PublicIpAddress')
ssh -i ~/.ssh/id_rsa ec2-user@$IP_ADDRESS
```

{{% notice info %}}
The DNS name of your EFS file system is constructed using the following convention:  
*file-system-id*.efs.*aws-region*.amazonaws.com  
For example,  
fs-dc13f9a4.efs.us-east-2.amazonaws.com
{{% /notice %}}

After you SSH into the EC2 instance, set an environment variable with its value set to the DNS name of your EFS file system constructed per the above convention. You may also get this information from the EFS Dashboard on the AWS Management Console.
```
EFS_FILE_SYSTEM_DNS_NAME=file-system-id.efs.aws-region.amazonaws.com
```

Execute the following set of commands which will mount the root directory of the EFS file system, identified by the file system DNS name, on to the **efs-mount-point** local directory of the EC2 instance and then create a sub-directory named **data** under the root directory of the EFS file system. 
 ```
sudo mkdir efs-mount-point
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
$EFS_FILE_SYSTEM_DNS_NAME:/ efs-mount-point
cd efs-mount-point
sudo mkdir data
```

Setup of the EFS file system is now complete and it is now ready for use by containers deployed on EKS. Log out of this EC2 instance and back to the CLI of your workspace.
