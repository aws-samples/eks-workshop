---
title: "Install Calico"
date: 2018-11-08T08:30:11-07:00
weight: 1
---

Apply the Calico manifest from the [aws/amazon-vpc-cni-k8s GitHub project](https://github.com/aws/amazon-vpc-cni-k8s). This creates the daemon sets in the kube-system namespace.


```
kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.6/calico.yaml
```
Let's go over few key features of the Calico manifest:

1) We see an annotation throughout; [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) are a way to attach **non-identifying** metadata to objects. This metadata is not used internally by Kubernetes, so they cannot be used to identify within k8s. Instead, they are used by external tools and libraries. Examples of annotations include build/release timestamps, client library information for debugging, or fields managed by a network policy like Calico in this case.

{{< output >}}
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: calico-node
  namespace: kube-system
  labels:
    k8s-app: calico-node
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        k8s-app: calico-node
      annotations:
        # This, along with the CriticalAddonsOnly toleration below,
        # marks the pod as a critical add-on, ensuring it gets
        # priority scheduling and that its resources are reserved
        # if it ever gets evicted.
        *scheduler**.alpha.kubernetes.io/critical-pod: ''*
        ...
{{< /output >}}
In contrast, [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors) in Kubernetes are intended to be used to specify **identifying** attributes for objects. They are used by selector queries or with label selectors. Since they are used internally by Kubernetes the structure of keys and values is constrained, to optimize queries.


2) We see that the manifest has a tolerations attribute. [Taints and tolerations](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) work together to ensure pods are not scheduled onto inappropriate nodes. Taints are applied to nodes, and the **only pods that can tolerate the taint are allowed to run on those nodes.** 

A taint consists of a key, a value for it and an effect, which can be:

* PreferNoSchedule: Prefer not to schedule intolerant pods to the tainted node
* NoSchedule: Do not schedule intolerant pods to the tainted node
* NoExecute: In addition to not scheduling, also evict intolerant pods that are already running on the node.
    
Like taints, tolerations also have a key value pair and an effect, with the addition of operator.
Here in the Calico manifest, we see tolerations has just one attribute: **Operator = exists**. This means the key value pair is omitted and the toleration will match any taint, ensuring it runs on all nodes.

{{< output >}}
 tolerations:
      - operator: Exists
{{< /output >}}
Watch the kube-system daemon sets and wait for the calico-node daemon set to have the DESIRED number of pods in the READY state.

```
kubectl get daemonset calico-node --namespace=kube-system
```
Expected Output:

{{< output >}}
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
calico-node   3         3         3       3            3           <none>          38s
{{< /output >}}





