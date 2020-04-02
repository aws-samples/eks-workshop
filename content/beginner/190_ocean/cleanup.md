---
title: "Cleanup"
date: 2019-04-09T00:00:00-03:00
weight: 20
draft: false
---

### Cleaning up

{{% notice note %}}
If you are running in your own account, you may keep your Ocean cluster and your Spot.io Account, as it is free of charge for up to 20 Nodes.
If you are running in an account that was created for you as part of an AWS event, there is no need to delete the resources used in this chapter as the AWS account will be closed automatically, but you should still proceed with the deletion of the Ocean cluster and closing of the Spot.io account.
{{% /notice %}}

To delete the resources used in this chapter from your EKS cluster: 
```
kubectl delete -f test_deployments.yaml
kubectl delete -f deployment spotinst-kubernetes-cluster-controller -n kube-system
```

In order to delete the Ocean cluster, on the Ocean dashboard click Actions, and then "Delete".
<img src="/images/ocean/actions_delete.png" alt="Actions - Delete" />

Click "Delete Cluster" in the prompt.
<img src="/images/ocean/delete_cluster.png" alt="Delete cluster" />

Next in order to delete your Spot.io Organization, click the blue "Chat" button on far right edge of your Console, and ask the 24/7 Spot.io Tech Support team to delete it. 

{{% notice info %}}
If your wish to make further use of your Spot.io Organization (to connect your real cloud account later, for example) you may leave your Organization intact, and instead ask the Spot.io Tech Support team to allow you to create a new account, and make that one your default. Once that is done, you can ask for the account you were using during the workshop to be deleted.
{{% /notice %}}
<img src="/images/ocean/chat.png" alt="Chat window" />

Finally, to detach your AWS cloud account from the platform, you need to delete the CloudFormation stack used to create the IAM Role and Policy during the account connection stage. Browse to the AWS ClouFormation Console, go to Stacks, Search for "spotinst-iam" and delete the Stack.

<img src="/images/ocean/delete_stack.png" alt="Delete CFN Stack" width="700"/>

