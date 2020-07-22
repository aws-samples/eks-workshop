---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 100
---

{{% notice note %}}
If you're running in an account that was created for you as part of an AWS event, there's no need to go through the cleanup stage - the account will be closed automatically.\
If you're running in your own account, make sure you run through these steps to make sure you don't encounter unwanted costs.
{{% /notice %}}

{{% notice tip %}}
Before you clean up the resources and complete the workshop, you may want to review the complete some of the optional exercises in previous section of this workshop; or alternatively, take a look at the content and modules available at **[eksworkshop.com](https://eksworkshop.com/)**. Perhaps there are modules that you would like to try on EC2 Spot instances!
{{% /notice %}}

## Cleaning up HPA, CA, and the Microservice
```
kubectl delete hpa monte-carlo-pi-service
kubectl delete -f ~/environment/cluster-autoscaler/cluster_autoscaler.yml
kubectl delete -f monte-carlo-pi-service.yml
helm delete kube-ops-view metrics-server
```

## Removing eks nodegroups
```
eksctl delete nodegroup -f spot_nodegroups.yml --approve
od_nodegroup=$(eksctl get nodegroup --cluster eksworkshop-eksctl | tail -n 1 | awk '{print $2}')
eksctl delete nodegroup --cluster eksworkshop-eksctl --name $od_nodegroup
```

This operation may take some time. Once that it completes you can proceed with the deletion of the cluster.

## Removing the cluster
```
eksctl delete cluster --name eksworkshop-eksctl
```


## Clean Cloud 9
```
aws ec2 delete-key-pair --key-name eksworkshop
CLOUD_9_IDS=$(aws cloud9 list-environments | jq -c ".environmentIds | flatten(0)" | sed -E -e 's/\[|\]|\"|//g' | sed 's/,/ /g')
CLOUD_9_WORKSHOP_ID=$(aws cloud9 describe-environments --environment-ids $CLOUD_9_IDS | jq '.environments | .[] | select(.name=="eksworkshop") | .id ' | sed -e 's/\"//g')
aws cloud9 delete-environment --environment-id $CLOUD_9_WORKSHOP_ID
```

{{% notice tip %}}
If you get any error while running this command, perhaps it might be caused because the name you selected for your cloud9 environment is different from **eksworkshop**. You can either find out and replace the name in the commands with the right name or [Use the console to delete the environment](https://docs.aws.amazon.com/cloud9/latest/user-guide/delete-environment.html).
{{% /notice %}}
