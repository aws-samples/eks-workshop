---
title: "Run sample workload"
date: 2021-04-08T03:21:44-07:00
weight: 20
draft: false
---

Now let's run a sample workload using one of the inbuilt example scripts that calculates the value of pi.


Before we begin with the sample workload, lets add a EKS managed nodegroup to have more resources for the sample spark job. 

Create a config file (addnodegroup.yaml) with details of a new EKS managed nodegroup. 

```sh
cat << EOF > addnodegroup.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

managedNodeGroups:
- name: emrnodegroup
  desiredCapacity: 3
  instanceType: m5.large
  ssh:
    enableSsm: true

EOF
```
Create the new EKS managed nodegroup. 

```sh
eksctl create nodegroup --config-file=addnodegroup.yaml
```
{{% notice info %}}
Launching a new EKS managed nodegroup will take a few minutes.
{{% /notice %}}

Check if the new nodegroup has been added to your cluster. 

```sh
kubectl get nodes # if we see 6 nodes in total with the 3 newly added nodes, we know we have authenticated correctly
```

Now lets get the virtual EMR clusters id and arn of the role that EMR uses for job execution.


```sh
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[].id" --output text)
```

```sh
export EMR_ROLE_ARN=$(aws iam get-role --role-name EMRContainers-JobExecutionRole --query Role.Arn --output text)
```

Lets start a sample spark job. 


```sh
aws emr-containers start-job-run \
  --virtual-cluster-id=$VIRTUAL_CLUSTER_ID \
  --name=pi-2 \
  --execution-role-arn=$EMR_ROLE_ARN \
  --release-label=emr-6.2.0-latest \
  --job-driver='{
    "sparkSubmitJobDriver": {
      "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
      "sparkSubmitParameters": "--conf spark.executor.instances=1 --conf spark.executor.memory=2G --conf spark.executor.cores=1 --conf spark.driver.cores=1"
    }
  }'
```

You will be able to see the completed job in EMR console. It should look like below:

![EMR Console of virtual cluster and jobs](/images/emr-on-eks/virtual-cluster1.png)


In the next section we will cover how to use spark history server to view job history. We will also take a look at how to send logs to s3 and cloudwatch.
