---
title: "Create the Mesh"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

The mesh component serves as the App Mesh foundation, and must be created first.  We'll call our mesh dj-app, and define it in the prod namespace by executing the following command from the repository's base directory:

```
kubectl create -f 4_create_initial_mesh_components/mesh.yaml
```

You should see output similar to:

{{< output >}}
mesh.appmesh.k8s.aws/dj-app created
{{< /output >}}

Since an App Mesh mesh is a custom resource, we can also use kubectl to view it via the get command.  Running the below command:

```
kubectl get meshes -nprod
```

yields:

{{< output >}}
NAME     AGE
dj-app   1h
{{< /output >}}

And similarly, as is the case for any of the custom resources we'll be interacting with in this tutorial, you can also view AWS App Mesh resources via the AWS CLI to list meshes:

```
aws appmesh list-meshes
```

which would output:
{{< output >}}
{
    "meshes": [
        {
            "meshName": "dj-app",
            "arn": "arn:aws:appmesh:us-west-2:123586676:mesh/dj-app"
        }
    ]
}
{{< /output >}}

or for example, to describe a mesh:

```
aws appmesh describe-mesh --mesh-name dj-app
```

would output:
{{< output >}}
{
    "mesh": {
        "status": {
            "status": "ACTIVE"
        },
        "meshName": "dj-app",
        "metadata": {
            "version": 1,
            "lastUpdatedAt": 1553233281.819,
            "createdAt": 1553233281.819,
            "arn": "arn:aws:appmesh:us-west-2:123586676:mesh/dj-app",
            "uid": "10d86ae0-ece7-4b1d-bc2d-08064d9b55e1"
        }
    }
}
{{< /output >}}
