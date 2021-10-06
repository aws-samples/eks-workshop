---
title: "Affinity and anti-affinity"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

### Affinity and anti-affinity

`nodeSelector` provides a very simple way to constrain pods to nodes with particular labels. The affinity/anti-affinity feature greatly extends the types of constraints you can express.

The key enhancements are:

- The language is more expressive (not just “AND of exact match”)
- You can indicate that the rule is “soft”/“preference” rather than a hard requirement, so if the scheduler can’t satisfy it, the pod will still be scheduled
- You can constrain against labels on other pods running on the node (or other topological domain), rather than against labels on the node itself, which allows rules about which pods can and cannot be co-located

The affinity feature consists of two types of affinity, “node affinity” and “inter-pod affinity/anti-affinity. Node affinity is like the existing `nodeSelector` (but with the first two benefits listed above), while inter-pod affinity/anti-affinity constrains against pod labels rather than node labels, as described in the third item listed above, in addition to having the first and second properties listed above.

### Node affinity

Node affinity was introduced as alpha in Kubernetes 1.2. Node affinity is conceptually similar to `nodeSelector` – it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.

There are currently two types of node affinity, called `requiredDuringSchedulingIgnoredDuringExecution` and `preferredDuringSchedulingIgnoredDuringExecution`.

You can think of them as “hard” and “soft” respectively, in the sense that the former specifies rules that must be met for a pod to be scheduled onto a node (just like nodeSelector but using a more expressive syntax), while the latter specifies preferences that the scheduler will try to enforce but will not guarantee. The “IgnoredDuringExecution” part of the names means that, similar to how nodeSelector works, if labels on a node change at runtime such that the affinity rules on a pod are no longer met, the pod will still continue to run on the node.

Thus an example of `requiredDuringSchedulingIgnoredDuringExecution` would be “only run the pod on nodes with Intel CPUs” and an example `preferredDuringSchedulingIgnoredDuringExecution` would be “try to run this set of pods in availability zone XYZ, but if it’s not possible, then allow some to run elsewhere”.

Node affinity is specified as field nodeAffinity of field affinity in the PodSpec.

Let's see an example of a pod that uses node affinity:

We are going to create another label on the same node as in the last example.

```bash
# export the first node name as a variable
export FIRST_NODE_NAME=$(kubectl get nodes -o json | jq -r '.items[0].metadata.name')

kubectl label nodes ${FIRST_NODE_NAME} azname=az1
```

And create an affinity:

```bash
cat <<EoF > ~/environment/pod-with-node-affinity.yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: azname
            operator: In
            values:
            - az1
            - az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: us.gcr.io/k8s-artifacts-prod/pause:2.0
EoF
```

This node affinity rule says the pod can only be placed on a node with a label whose key is `azname` and whose value is either `az1` or `az2`. In addition, among nodes that meet that criteria, nodes with a label whose key is `another-node-label-key` and whose value is `another-node-label-value` should be preferred.

Let's apply this:

```bash
kubectl apply -f ~/environment/pod-with-node-affinity.yaml
```

And check if it worked with:

```bash
kubectl get pods -o wide
```

{{< output >}}
NAME                 READY   STATUS    RESTARTS   AGE   IP                NODE                                           NOMINATED NODE   READINESS GATES
nginx                1/1     Running   0          93s   192.168.155.38    ip-192-168-155-36.us-east-2.compute.internal   <none>           <none>
with-node-affinity   1/1     Running   0          6s    192.168.156.139   ip-192-168-155-36.us-east-2.compute.internal   <none>           <none>
{{< /output >}}

We are going to apply the label to a different node. So first, let's clean the label and delete the Pod.

```bash
kubectl delete -f ~/environment/pod-with-node-affinity.yaml

kubectl label nodes ${FIRST_NODE_NAME} azname-
```

We are applying the label to second node now:

```bash
export SECOND_NODE_NAME=$(kubectl get nodes -o json | jq -r '.items[1].metadata.name')

kubectl label nodes ${SECOND_NODE_NAME} azname=az1
kubectl apply -f ~/environment/pod-with-node-affinity.yaml
```

And check if it works with:

```bash
kubectl get pods -o wide
```

{{< output >}}
NAME                 READY   STATUS    RESTARTS   AGE     IP                NODE                                            NOMINATED NODE   READINESS GATES
nginx                1/1     Running   0          2m14s   192.168.155.38    ip-192-168-155-36.us-east-2.compute.internal    <none>           <none>
with-node-affinity   1/1     Running   0          11s     192.168.166.141   ip-192-168-168-110.us-east-2.compute.internal   <none>           <none>
{{< /output >}}


You can see the operator `In` being used in the example.

The new node affinity syntax supports the following operators: `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`. You can use `NotIn` and `DoesNotExist` to achieve node anti-affinity behavior.

If you specify both `nodeSelector` and `nodeAffinity`, both must be satisfied for the pod to be scheduled onto a candidate node.

If you specify multiple `nodeSelectorTerms` associated with `nodeAffinity` types, then the pod can be scheduled onto a node if one of the `nodeSelectorTerms` is satisfied.

If you specify multiple `matchExpressions` associated with `nodeSelectorTerms`, then the pod can be scheduled onto a node only if all `matchExpressions` can be satisfied.

If you remove or change the label of the node where the pod is scheduled, the pod won’t be removed. In other words, the affinity selection works only at the time of scheduling the pod.

The weight field in `preferredDuringSchedulingIgnoredDuringExecution` is in the range 1-100. For each node that meets all of the scheduling requirements (resource requests, RequiredDuringScheduling affinity expressions, etc.), the scheduler will compute a sum by iterating through the elements of this field and adding “weight” to the sum if the node matches the corresponding MatchExpressions. This score is then combined with the scores of other priority functions for the node. The node(s) with the highest total score are the most preferred.

We are now ready to delete both pods

```bash
kubectl delete -f ~/environment/pod-nginx.yaml
kubectl delete -f ~/environment/pod-with-node-affinity.yaml
```
