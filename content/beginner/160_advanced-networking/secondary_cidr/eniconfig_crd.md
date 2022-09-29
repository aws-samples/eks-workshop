---
title: "Create CRDs"
date: 2021-06-13T16:34:28+0000
weight: 40
---

### Create custom resources for ENIConfig CRD
As next step, we will add custom resources to ENIConfig custom resource definition (CRD). CRDs are extensions of Kubernetes API that stores collection of API objects of certain kind. In this case, we will store VPC Subnet and SecurityGroup configuration information in these CRDs so that Worker nodes can access them to configure VPC CNI plugin.

You should have ENIConfig CRD already installed with latest CNI version (1.3+). You can check if its installed by running this command.
```
kubectl get crd
```
You should see a response similar to this
{{< output >}}
NAME                               CREATED AT
eniconfigs.crd.k8s.amazonaws.com   2021-06-13T14:02:40Z
{{< /output >}}
If you don't have ENIConfig installed, you can install it by using this command
```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.11/config/master/aws-k8s-cni.yaml
```
Create custom resources for each subnet by replacing **Subnet** and **SecurityGroup IDs**. Since we created three secondary subnets, we need to create three custom resources.

Generate a template file `pod-netconfig.template` for ENIConfig 
```
cat <<EOF >pod-netconfig.template
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
 name: \${AZ}
spec:
 subnet: \${SUBNET_ID}
 securityGroups: [ \${NETCONFIG_SECURITY_GROUPS} ]
EOF
```

Check the AZs and Subnet IDs for these subnets. Make note of AZ info as you will need this when you apply annotation to Worker nodes using custom network config
```
aws ec2 describe-subnets  --filters "Name=cidr-block,Values=100.64.*" --query 'Subnets[*].[CidrBlock,SubnetId,AvailabilityZone]' --output table
```
{{< output >}}
--------------------------------------------------------------
|                       DescribeSubnets                      |
+-----------------+----------------------------+-------------+
|  100.64.64.0/19 |  subnet-07dab05836e4abe91  |  us-west-2a |
|  100.64.0.0/19  |  subnet-0692cd08cc4df9b6a  |  us-west-2c |
|  100.64.32.0/19 |  subnet-04f960ffc8be6865c  |  us-west-2b |
+-----------------+----------------------------+-------------+
{{< /output >}}

Ensure new nodes are up and listed with 'Ready' status. 
```
kubectl get nodes  # Make sure new nodes are listed with 'Ready' status
```
{{< output >}}
NAME                                           STATUS   ROLES    AGE   VERSION
ip-192-168-33-232.us-west-2.compute.internal   Ready    <none>   26m   v1.21.12-eks-5308cf7
ip-192-168-87-115.us-west-2.compute.internal   Ready    <none>   23m   v1.21.12-eks-5308cf7
ip-192-168-9-141.us-west-2.compute.internal    Ready    <none>   27m   v1.21.12-eks-5308cf7
{{< /output >}}
 
{{% notice warning %}}
 Wait till all three nodes show `Ready` status before moving to the next step.
{{% /notice %}}
 
Check your Worker Node SecurityGroup
```
INSTANCE_IDS=(`aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --output text`)

export NETCONFIG_SECURITY_GROUPS=$(for i in "${INSTANCE_IDS[@]}"; do  aws ec2 describe-instances --instance-ids $i | jq -r '.Reservations[].Instances[].SecurityGroups[].GroupId'; done  | sort | uniq | awk -vORS=, '{print $1 }' | sed 's/,$//')

echo $NETCONFIG_SECURITY_GROUPS
```
{{< output >}}
sg-070d03008bda531ad
{{< /output >}}
 
Note: We are using same SecurityGroup for pods as your Worker Nodes but you can change these and use custom SecurityGroups for your Pod Networking
 
Check the `yq` command runs successfully. Refer to `yq` setup in [Install Kubernetes Tools](https://www.eksworkshop.com/020_prerequisites/k8stools/)
```
yq --help >/dev/null  && echo "yq command working" || "yq command not working"
```
{{< output >}}
 yq command working
{{< /output >}}
 
Create ENIConfig custom resources. One file per AZ. 
```
cd $HOME/environment
mkdir -p eniconfig
while IFS= read -r line
do
 arr=($line)
 OUTPUT=`AZ=${arr[0]} SUBNET_ID=${arr[1]} envsubst < pod-netconfig.template | yq eval -P`
 FILENAME=${arr[0]}.yaml
 echo "Creating ENIConfig file:  eniconfig/$FILENAME"
 cat <<EOF >eniconfig/$FILENAME
$OUTPUT
EOF
done< <(aws ec2 describe-subnets  --filters "Name=cidr-block,Values=100.64.*" --query 'Subnets[*].[AvailabilityZone,SubnetId]' --output text)
```

Your output may look different, based on your AWS region and subnets.
{{< output >}}
Creating ENIConfig file:  eniconfig/us-west-2c.yaml
Creating ENIConfig file:  eniconfig/us-west-2a.yaml
Creating ENIConfig file:  eniconfig/us-west-2b.yaml
{{< /output >}}
 
Examine the content of these files, it should look similar to below. For example `eniconfig/us-east-2a.yaml`
{{< output >}}
apiVersion: crd.k8s.amazonaws.com/v1alpha1
kind: ENIConfig
metadata:
  name: us-west-2c
spec:
  subnet: subnet-0516a2f4e239f8d88
  securityGroups:
    - sg-0354b6919e1f2b0a5
{{< /output >}}


Apply the CRDs for each AZ.
```
cd $HOME/environment
kubectl apply -f eniconfig
```

Verify, ENIConfig custom resource for each subnet. It is highly recommended using a value of `name` that matches with the AZ of the subnet, because this makes the deployment simpler later.
```
kubectl get eniconfig
```
{{< output >}}
NAME         AGE
us-west-2a   85m
us-west-2b   85m
us-west-2c   85m
{{< /output >}}
 
Check the instance details using this command as you will need AZ info when you apply annotation to Worker nodes using custom network config
```
aws ec2 describe-instances --filters "Name=tag-key,Values=eks:cluster-name" "Name=tag-value,Values=eksworkshop*" --query 'Reservations[*].Instances[*].[PrivateDnsName,Tags[?Key==`eks:nodegroup-name`].Value|[0],Placement.AvailabilityZone,PrivateIpAddress,PublicIpAddress]' --output table  
```
{{< output >}}
------------------------------------------------------------------------------------------------------------------------------------------
|                                                            DescribeInstances                                                           |
+-----------------------------------------------+---------------------------------------+-------------+-----------------+----------------+
|  ip-192-168-9-228.us-east-2.compute.internal  |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-west-2c |  192.168.9.228  |  18.191.57.131 |
|  ip-192-168-71-211.us-east-2.compute.internal |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-west-2a |  192.168.71.211 |  18.221.77.249 |
|  ip-192-168-33-135.us-east-2.compute.internal |  eksworkshop-eksctl-ng-475d4bc8-Node  |  us-west-2b |  192.168.33.135 |  13.59.167.90  |
+-----------------------------------------------+---------------------------------------+-------------+-----------------+----------------+
{{< /output >}}

As last step, we will annotate nodes with custom network configs.

{{% notice warning %}}
Be sure to annotate the instance with config that matches correct AZ. For example, in my environment instance ip-192-168-33-135.us-west-2.compute.internal is in us-west-2b. So, I will apply ENIConfig **us-west-2b** to this instance. Similarly, I will apply **us-west-2a** to ip-192-168-71-211.us-west-2.compute.internal and **us-west-2c** to ip-192-168-9-228.us-west-2.compute.internal
{{% /notice %}}

```
kubectl annotate node <nodename>.<region>.compute.internal k8s.amazonaws.com/eniConfig=<ENIConfig-name-for-az>
```
As an example, here is what I would run in my environment
{{< output >}}
kubectl annotate node ip-192-168-33-135.us-west-2.compute.internal k8s.amazonaws.com/eniConfig=us-west-2b
{{< /output >}}
You should now see secondary IP address from extended CIDR assigned to annotated nodes.

#### Additional notes on ENIConfig naming and automatic matching

We intentially used `ENIConfig` name with its matching AZ name for a subnet (`us-west-2a`, `us-west-2b`, `us-west-2c`). Kubernetes also applies labels to nodes such as `failure-domain.beta.kubernetes.io/zone` with matching AZ name as well. 

{{< output >}}
 kubectl describe nodes | grep 'failure-domain.beta.kubernetes.io/zone'
                    failure-domain.beta.kubernetes.io/zone=us-west-2a
                    failure-domain.beta.kubernetes.io/zone=us-west-2b
                    failure-domain.beta.kubernetes.io/zone=us-west-2c
{{< /output >}}
 
You can then enable Kubernetes to automatically apply the corresponding ENIConfig for the node's Availability Zone with the following command. 
```
 kubectl set env daemonset aws-node -n kube-system ENI_CONFIG_LABEL_DEF=failure-domain.beta.kubernetes.io/zone
```
Kubernetes will now automatically apply the corresponding `ENIConfig` matching the nodes AZ, and no need to manually annotate the new EC2 instance with ENIConfig.
