---
title: "Cleanup"
date: 2019-04-09T00:00:00-03:00
weight: 20
draft: false
---

### Cleaning up

{{% notice note %}}
If you are running in your own account, you may keep your Ocean cluster and your Spot Account, as it is free of charge for up to 20 Nodes.
If you are running in an account that was created for you as part of an AWS event, there is no need to delete the resources used in this chapter as the AWS account will be closed automatically, but you should still proceed with the deletion of the Ocean cluster and closing of the Spot account.
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

Next in order to delete your Spot Organization, click the blue "Chat" button on far right edge of your Console, and ask the 24/7 Spot Tech Support team to delete it. 

{{% notice info %}}
If your wish to make further use of your Spot Organization (to connect your real cloud account later, for example) you may leave your Organization intact, and instead ask the Spot Tech Support team to allow you to create a new account, and make that one your default. Once that is done, you can ask for the account you were using during the workshop to be deleted.
{{% /notice %}}
<img src="/images/ocean/chat.png" alt="Chat window" />

Finally, to detach your AWS cloud account from the platform, you need to delete the IAM Role created via CFN during the account connection stage. Browse to the AWS IAM Console, go to Roles under Access Management, Search for "spotinst-iam-stack" and delete the role.
**Question: shouldn't the user delete the CFn stack that created the IAM role, and not the IAM role itself?**

<img src="/images/ocean/delete_role.png" alt="Delete IAM Role" width="700"/>

