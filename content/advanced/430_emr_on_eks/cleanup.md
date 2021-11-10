---
title: "Cleanup"
date: 2021-05-11T13:38:18+08:00
weight: 100
draft: false
---

For more hands-on experience, see the dedicated [EMR on EKS Workshop](https://emr-on-eks.workshop.aws/).
#### Empty and delete S3 buckets

```sh
aws s3 rm $s3DemoBucket --recursive
aws s3 rb $s3DemoBucket --force

```

#### Delete IAM Role and policiess

```sh
aws iam delete-role-policy --role-name EMRContainers-JobExecutionRole --policy-name review-data-access
aws iam delete-role-policy --role-name EMRContainers-JobExecutionRole --policy-name EMR-Containers-Job-Execution
aws iam delete-role --role-name EMRContainers-JobExecutionRole

```


#### Delete Virtual Cluster
Cluster cannot be deleted unless the pods in pending state are cleaned up. Lets find out running jobs and cancel them. 

```sh
for Job_id in $(aws emr-containers list-job-runs --states RUNNING --virtual-cluster-id ${VIRTUAL_CLUSTER_ID} --query "jobRuns[?state=='RUNNING'].id" --output text ); do aws emr-containers cancel-job-run --id ${Job_id} --virtual-cluster-id ${VIRTUAL_CLUSTER_ID}; done
```

We can now delete the cluster
```sh
aws emr-containers delete-virtual-cluster --id ${VIRTUAL_CLUSTER_ID}
```

To delete the namespace, the node group and the Fargate profile created by this module, run the following commands

```sh
kubectl delete namespace spark

eksctl delete fargateprofile --cluster=eksworkshop-eksctl --name emr --wait

eksctl delete nodegroup --config-file=addnodegroup.yaml --approve
eksctl delete nodegroup --config-file=addnodegroup-spot.yaml --approve
eksctl delete nodegroup --config-file=addnodegroup-nytaxi.yaml --approve

```