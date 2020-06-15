---
title: "Test Permissions"
date: 2018-08-07T08:30:11-07:00
weight: 40
hidden: true
---

To test that your worker nodes are able to use these permissions correctly, we'll run a job that attempts to list all existing meshes.

Run this command to set the script to run against the correct region:

```
sed -i'.old' -e 's/\"us-west-2\"/\"'$AWS_REGION'\"/' awscli.yaml
```

Next, execute the job:

```
kubectl apply -f awscli.yaml
```
Make sure its completed by issuing the command:

```
kubectl get jobs
```

And see that desired and successful are both one:

```
NAME     DESIRED   SUCCESSFUL   AGE
awscli   1         1            1m
```
Inspect the output of the job:

```
kubectl logs jobs/awscli
```

The output of this command will illustrate if your nodes can make App Mesh API calls successfully as well.

This output shows the workers have proper access:

{{< output >}}
{
    "meshes": []
}
{{< /output >}}

And this output shows they don't:

{{< output >}}
An error occurred (AccessDeniedException) when calling the ListMeshes operation: User: arn:aws:iam::123abc:user/foo is not authorized to perform: appmesh:ListMeshes on resource: *
{{< /output >}}

If you need to troubleshoot further, in order to run the job again to test, you must first delete it:

```
kubectl delete jobs/awscli
```

Once you've successfully tested for the proper permissions, continue on to the next step.
