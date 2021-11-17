---
title: "nodeSelector"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

`nodeSelector` is the simplest recommended form of node selection constraint. `nodeSelector` is a field of PodSpec. It specifies a map of key-value pairs. For the pod to be eligible to run on a node, the node must have each of the indicated key-value pairs as labels (it can have additional labels as well). The most common usage is one key-value pair.

### Attach a label to the node

Run kubectl get nodes to get the names of your cluster’s nodes.

```bash
kubectl get nodes
```

Output will look like:

{{< output >}}
NAME                                            STATUS   ROLES    AGE     VERSION
ip-192-168-155-36.us-east-2.compute.internal    Ready    <none>   2d23h   v1.20.4-eks-6b7464
ip-192-168-168-110.us-east-2.compute.internal   Ready    <none>   2d23h   v1.20.4-eks-6b7464
ip-192-168-97-12.us-east-2.compute.internal     Ready    <none>   2d23h   v1.20.4-eks-6b7464
{{< /output >}}

We will add a new label `disktype=ssd` to the first node on this list.

But first, let's confirm the label hasn't been assigned to any nodes by filtering the previous using the selector option.

```bash
kubectl get nodes --selector disktype=ssd
```

Output:

{{< output >}}
No resources found
{{< /output >}}

To add a label to the first node, we can run these commands:

```bash
# export the first node name as a variable
export FIRST_NODE_NAME=$(kubectl get nodes -o json | jq -r '.items[0].metadata.name')

# add the label to the node
kubectl label nodes ${FIRST_NODE_NAME} disktype=ssd
```

Output will look like:

{{< output >}}
node/ip-192-168-155-36.us-east-2.compute.internal labeled
{{< /output >}}

We can verify that it worked by re-running the `kubectl get nodes --selector` command.

```bash
kubectl get nodes --selector disktype=ssd
```

Output will look like:

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-155-36.us-east-2.compute.internal   Ready    <none>   2d23h   v1.20.4-eks-6b7464
{{< /output >}}

### Deploy a nginx pod only to the node with the new label

We will now create a simple pod creating a file with the `nodeSelector` in the pod spec.

```bash
cat <<EoF > ~/environment/pod-nginx.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
EoF
```

Then you run:

```bash
kubectl apply -f ~/environment/pod-nginx.yaml
```

The Pod will get scheduled on the node that you attached the label to. You can verify that it worked by running:

```bash
kubectl get pods -o wide
```

Output will look like:

{{< output >}}
NAME    READY   STATUS              RESTARTS   AGE   IP       NODE                                          NOMINATED NODE   READINESS GATES
nginx   0/1     ContainerCreating   0          4s    <none>   ip-192-168-155-36.us-east-2.compute.internal   <none>           <none>
{{< /output >}}

The `NODE` name should match the output of the command below:

```bash
kubectl get nodes --selector disktype=ssd
```

Sample Output

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-155-36.us-east-2.compute.internal   Ready    <none>   2d23h   v1.20.4-eks-6b7464
{{< /output >}}
