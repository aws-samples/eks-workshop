---
title: "Test the Cluster"
date: 2018-08-07T13:36:57-07:00
weight: 30
---
#### Test the cluster:
Confirm your Nodes, if we see our 2 nodes, we know we have authenticated correctly:

```
kubectl get nodes 
```

Export the Managed Group Worker Role Name for use throughout the workshop.

{{% notice tip %}}
Some of the optional exercises may require you to add extra IAM policies to the managed group role
for the nodes to get access to services like Cloudwatch, AppMesh, X-Ray. You can always com back to this section or the environment variable `$ROLE_NAME` to refer to the role.
{{% /notice %}}

```
NODE_GROUP_NAME=$(eksctl get nodegroup --cluster eksworkshop-eksctl -o json | jq -r '.[].Name')
ROLE_NAME=$(aws eks describe-nodegroup --cluster-name eksworkshop-eksctl --nodegroup-name $NODE_GROUP_NAME | jq -r '.nodegroup["nodeRole"]' | cut -f2 -d/)
echo "export ROLE_NAME=${ROLE_NAME}" >> ~/.bash_profile
```




#### Congratulations!

You now have a fully working Amazon EKS Cluster that is ready to use!

{{% notice tip %}}
Explore the Elastic Kubernetes Service (EKS) section in the AWS Console and the properties of the newly created EKS cluster.
{{% /notice %}}
