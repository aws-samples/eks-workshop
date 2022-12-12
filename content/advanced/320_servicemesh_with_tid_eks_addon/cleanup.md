---
title: "Cleanup"
date: 2019-03-20T13:59:44+01:00
weight: 70
draft: false
---

To cleanup, follow the below steps.

To remove `helloworld` **Blue (v2)** and **Green (v1)** applications - all is needed to remove the corresponding namespaces:

```bash
kubectl delete namespace green
kubectl delete namespace blue
```

{{% notice info %}}
You can ignore the errors for non-existent resources because they may have been deleted hierarchically.
{{% /notice %}}

To remove EKS TID add-on issue `aws cli` command per below:

```bash
aws eks delete-addon --addon-name tetrate-io_istio-distro --cluster-name <CLUSTER_NAME>
```

The output will look like below. Addon will be removed in a matter of 1-2 minutes
{{< output >}}
$ aws eks delete-addon --addon-name tetrate-io_istio-distro --cluster-name live-0-workshop --region us-west-2
{
    "addon": {
        "addonName": "tetrate-io_istio-distro",
        "clusterName": "live-0-workshop",
        "status": "DELETING",
        "addonVersion": "v1.15.3-eksbuild.0",
        "health": {
            "issues": []
        },
        "addonArn": "arn:aws:eks:us-west-2:1XXXXXXXXXX1:addon/live-0-workshop/tetrate-io_istio-distro/14c276eb-c851-e308-9c0e-4e71d8c303ad",
        "createdAt": "2022-12-07T19:27:18.465000+01:00",
        "modifiedAt": "2022-12-12T15:48:54.496000+01:00",
        "tags": {}
    }
}
{{</ output >}}