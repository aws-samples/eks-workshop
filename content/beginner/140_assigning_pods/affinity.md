---
title: "Affinity and anti-affinity"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

#### Affinity and anti-affinity
nodeSelector provides a very simple way to constrain pods to nodes with particular labels. The affinity/anti-affinity feature, currently in beta, greatly extends the types of constraints you can express. The key enhancements are:

- The language is more expressive (not just “AND of exact match”)
- You can indicate that the rule is “soft”/“preference” rather than a hard requirement, so if the scheduler can’t satisfy it, the pod will still be scheduled
- You can constrain against labels on other pods running on the node (or other topological domain), rather than against labels on the node itself, which allows rules about which pods can and cannot be co-located

The affinity feature consists of two types of affinity, “node affinity” and “inter-pod affinity/anti-affinity”. Node affinity is like the existing nodeSelector (but with the first two benefits listed above), while inter-pod affinity/anti-affinity constrains against pod labels rather than node labels, as described in the third item listed above, in addition to having the first and second properties listed above.

#### Node affinity (beta feature)
Node affinity was introduced as alpha in Kubernetes 1.2. Node affinity is conceptually similar to nodeSelector – it allows you to constrain which nodes your pod is eligible to be scheduled on, based on labels on the node.

There are currently two types of node affinity, called `requiredDuringSchedulingIgnoredDuringExecution` and `preferredDuringSchedulingIgnoredDuringExecution`. 

You can think of them as “hard” and “soft” respectively, in the sense that the former specifies rules that must be met for a pod to be scheduled onto a node (just like nodeSelector but using a more expressive syntax), while the latter specifies preferences that the scheduler will try to enforce but will not guarantee. The “IgnoredDuringExecution” part of the names means that, similar to how nodeSelector works, if labels on a node change at runtime such that the affinity rules on a pod are no longer met, the pod will still continue to run on the node. 

Thus an example of `requiredDuringSchedulingIgnoredDuringExecution` would be “only run the pod on nodes with Intel CPUs” and an example `preferredDuringSchedulingIgnoredDuringExecution` would be “try to run this set of pods in availability zone XYZ, but if it’s not possible, then allow some to run elsewhere”.

Node affinity is specified as field nodeAffinity of field affinity in the PodSpec.


Let's see an example of a pod that uses node affinity:

We are going to create another label in the same node that in the last example:
```
kubectl label nodes ip-192-168-15-64.us-west-2.compute.internal azname=az1
```
And create an affinity:
```
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

Let's apply this 
```
kubectl apply -f ~/environment/pod-with-node-affinity.yaml
```
And check if it worked with `kubectl get pods -o wide`
{{< output >}}
NAME                 READY     STATUS    RESTARTS   AGE       IP               NODE                                          NOMINATED NODE
nginx                1/1       Running   0          35m       192.168.10.13    ip-192-168-15-64.us-west-2.compute.internal   <none>
with-node-affinity   1/1       Running   0          29s       192.168.14.121   ip-192-168-15-64.us-west-2.compute.internal   <none>
{{< /output >}}
Now let's try to put the affinity in another node
We are going to put the label in a different node so first, let's clean the label and delete the Pod.
```
kubectl delete -f ~/environment/pod-with-node-affinity.yaml
kubectl label nodes ip-192-168-15-64.us-west-2.compute.internal azname-
```
We are putting the label to the node ip-192-168-86-147.us-west-2.compute.internal now
```
kubectl label nodes ip-192-168-86-147.us-west-2.compute.internal azname=az1
kubectl apply -f ~/environment/pod-with-node-affinity.yaml
```
And check if it works with `kubectl get pods -o wide` 
{{< output >}}
NAME                 READY     STATUS    RESTARTS   AGE       IP               NODE                                           NOMINATED NODE
nginx                1/1       Running   0          43m       192.168.10.13    ip-192-168-15-64.us-west-2.compute.internal    <none>
with-node-affinity   1/1       Running   0          42s       192.168.68.249   ip-192-168-86-147.us-west-2.compute.internal   <none>
{{< /output >}}

You can see the operator In being used in the example. The new node affinity syntax supports the following operators: `In, NotIn, Exists, DoesNotExist, Gt, Lt`. You can use `NotIn` and `DoesNotExist` to achieve node anti-affinity behavior.

- If you specify both `nodeSelector` and `nodeAffinity`, both must be satisfied for the pod to be scheduled onto a candidate node.
- If you specify multiple `nodeSelectorTerms` associated with `nodeAffinity` types, then the pod can be scheduled onto a node if one of the `nodeSelectorTerms` is satisfied.
- If you specify multiple `matchExpressions` associated with `nodeSelectorTerms`, then the pod can be scheduled onto a node only if all `matchExpressions` can be satisfied.
- If you remove or change the label of the node where the pod is scheduled, the pod won’t be removed. In other words, the affinity selection works only at the time of scheduling the pod.

The weight field in `preferredDuringSchedulingIgnoredDuringExecution` is in the range 1-100. For each node that meets all of the scheduling requirements (resource request, RequiredDuringScheduling affinity expressions, etc.), the scheduler will compute a sum by iterating through the elements of this field and adding “weight” to the sum if the node matches the corresponding MatchExpressions. This score is then combined with the scores of other priority functions for the node. The node(s) with the highest total score are the most preferred.
