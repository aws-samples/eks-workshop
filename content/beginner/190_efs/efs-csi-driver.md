---
title: "EFS Provisioner for EKS with CSI Driver"
date: 2021-07-01T00:00:00-05:00
weight: 12
draft: false
---

## About the Amazon EFS CSI Driver
On Amazon EKS, the open-source [EFS Container Storage Interface (CSI)](https://github.com/kubernetes-sigs/aws-efs-csi-driver) driver provides a CSI interface that allows Kubernetes clusters running on AWS to manage the lifecycle of Amazon EFS file systems.

## Configure IAM Policy and Role for Service Account
Firstly, we need to create an IAM policy to allow CSI driver to call EFS APIs on your behalf.
```sh
export EFS_CSI_POLICY_NAME="AmazonEKS_EFS_CSI_Driver_Policy"
export EFS_CSI_SERVICEACCOUNT_NAME="efs-csi-controller-sa"

mkdir ${HOME}/environment/efs
cd ${HOME}/environment/efs

# download the IAM policy document
curl -o efs-csi-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-efs-csi-driver/v1.3.2/docs/iam-policy-example.json

# Create the IAM policy
aws iam create-policy \
    --policy-name ${EFS_CSI_POLICY_NAME} \
    --policy-document file://efs-csi-policy.json

# export the policy ARN as a variable
export EFS_CSI_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`'$EFS_CSI_POLICY_NAME'`].Arn' --output text)
```

We'll use `eksctl` to create an IAM role with the IAM policy attached to it, and associate the kubernetes service account with the IAM role.
```sh
eksctl create iamserviceaccount \
    --name $EFS_CSI_SERVICEACCOUNT_NAME \
    --namespace kube-system \
    --cluster eksworkshop-eksctl \
    --attach-policy-arn $EFS_CSI_POLICY_ARN \
    --approve \
    --override-existing-serviceaccounts \
    --region $AWS_REGION
```

## Deploy EFS CSI Driver
Now, we are going to deploy the driver using helm.

{{% notice note %}}
If Helm is not installed, [click here the instruction](/beginner/060_helm/helm_intro/install/)
{{% /notice %}}

```sh
# add the aws-efs-csi-driver as a helm repo
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/

# update the repo
helm repo update

# install the chart
helm upgrade -i aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver \
    --namespace kube-system \
    --set controller.serviceAccount.create=false \
    --set controller.serviceAccount.name=$EFS_CSI_SERVICEACCOUNT_NAME
```

Verify pods have been deployed:
```
kubectl get pods -n kube-system
```

Should return new pods with csi driver:

Output: 
{{< output >}}
NAME                              READY   STATUS    RESTARTS   AGE
efs-csi-controller-8fdf586d5-5sqf5   3/3     Running   0          66s
efs-csi-controller-8fdf586d5-j9nbl   3/3     Running   0          66s
efs-csi-node-bhhbv                   3/3     Running   0          66s
efs-csi-node-cbhzk                   3/3     Running   0          66s
efs-csi-node-xwkd2                   3/3     Running   0          66s
{{< /output >}}


## Create Persistent Volume
Next we will deploy a persistent volume using the EFS created. 
```
cd ${HOME}/environment/efs
wget https://eksworkshop.com/beginner/190_efs/efs.files/efs-pvc.yaml
```

We need to update this manifest with the EFS ID created:
```
sed -i "s/EFS_VOLUME_ID/$FILE_SYSTEM_ID/g" efs-pvc.yaml
```

And then apply:
```
kubectl apply -f efs-pvc.yaml
```

Next, check if a PVC resource was created. The output from the command should look similar to what is shown below, with the **STATUS** field set to **Bound**.
```
kubectl get pvc -n storage
```

Output: 
{{< output >}}
NAME                STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
efs-storage-claim   Bound    efs-pvc   5Gi        RWX            efs-sc         4s
{{< /output >}}


A PV corresponding to the above PVC is dynamically created. Check its status with the following command.
```
kubectl get pv
```

Output: 
{{< output >}}
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS   REASON   AGE
efs-pvc   5Gi        RWX            Retain           Bound    storage/efs-storage-claim   efs-sc                  20s
{{< /output >}}
