---
title: "Prereqs"
date: 2021-5-01T09:00:00-00:00
weight: 5
draft: false
---

To get ready to use Pixie to debug an application on a Kubernetes cluster, we will:

- Add a node group to scale the EKS cluster.
- Deploy a demo microservices app.
- Visit the microservices app front-end and trigger a bug.

### Add a node group

To accommodate the pods deployed by Pixie and the microservices demo application, we will add a managed node group to scale the `eksworkshop-eksctl` cluster.

Curl the node group config file and use `eksctl` to create the new `pixie-demo-ng` node group:

```bash
curl -O https://raw.githubusercontent.com/pixie-labs/pixie-demos/main/eks-workshop/clusterconfig.yaml
envsubst < clusterconfig.yaml | eksctl create nodegroup -f -
```

{{% notice info %}}
The creation of the node group will take about 3 - 5 minutes.
{{% /notice %}}

Confirm that the new nodes joined the cluster correctly. You should see 3 nodes added to the cluster.

```bash
kubectl get nodes --sort-by=.metadata.creationTimestamp
```

{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-168-89-204.us-west-2.compute.internal   Ready    <none>   3h55m   v1.21.12-eks-5308cf7
ip-192-168-61-130.us-west-2.compute.internal   Ready    <none>   3h55m   v1.21.12-eks-5308cf7
ip-192-168-23-16.us-west-2.compute.internal    Ready    <none>   3h55m   v1.21.12-eks-5308cf7
ip-192-168-77-36.us-west-2.compute.internal    Ready    <none>   117s    v1.21.12-eks-5308cf7
ip-192-168-19-12.us-west-2.compute.internal    Ready    <none>   107s    v1.21.12-eks-5308cf7
ip-192-168-55-118.us-west-2.compute.internal   Ready    <none>   106s    v1.21.12-eks-5308cf7
{{< /output >}}

### Deploy the demo microservices app

To test out Pixie, we will deploy a modified version of [Weavework’s Sock Shop](https://microservices-demo.github.io/) microservices application. This demo app does not contain any manual instrumentation. Minimal modifications were made to set pod resource limits and create a bug in one of the services.

Curl the config file and deploy the demo using `kubectl`:

```bash
curl -O https://raw.githubusercontent.com/pixie-labs/pixie-demos/main/eks-workshop/complete-demo.yaml
kubectl apply -f complete-demo.yaml
```

{{% notice info %}}
Deploying the microservices demo will take about 3-5 minutes.
{{% /notice %}}

Confirm that the application components have been deployed to the `px-sock-shop` namespace:

```bash
kubectl get pods -n px-sock-shop
```

You should see output similar to that below. All pods should be ready and available before proceeding.

{{< output >}}
NAME                           READY   STATUS    RESTARTS   AGE
carts-5fc45568c4-nhv2q         1/1     Running   0          35m
carts-db-64ff6c747f-zhh7z      1/1     Running   0          35m
catalogue-8f6fdb6d8-dl5fd      1/1     Running   0          35m
catalogue-db-69cf48ff8-pz9w8   1/1     Running   0          35m
front-end-5756d95c69-7n8pc     1/1     Running   0          35m
load-test-5d887bfd7d-p7vfd     1/1     Running   0          35m
orders-77c57c89dc-qm2gj        1/1     Running   0          35m
orders-db-df75f545f-fbcnl      1/1     Running   0          35m
payment-7f95f9f77-9c2rm        1/1     Running   0          35m
queue-master-bd556c45-xq6pp    1/1     Running   0          35m
rabbitmq-68d55c844f-swknh      1/1     Running   0          35m
shipping-745b9d8755-glb8x      1/1     Running   0          35m
user-5cf8959676-v6jtx          1/1     Running   0          35m
user-db-794cfdf85b-4f6rq       1/1     Running   0          35m
{{< /output >}}

### Visit the Sock Shop application

The Sock Shop's `front-end` service is exposed onto an external IP address using a `LoadBalancer`.  Grab the Load Balancer address using:

```bash
export SERVICE_IP=$(kubectl -n px-sock-shop get svc front-end --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")

echo http://$SERVICE_IP/
```

You should see output similar to that below.

{{< output >}}
workshop:~/environment $ echo http://$SERVICE_IP/
http://a22bf691105874cf0a5468a2ddce7f19-2030728129.us-west-2.elb.amazonaws.com/
{{< /output >}}

{{% notice info %}}
When the `front-end` service is first deployed, it can take several minutes for the Load Balancer to be created and DNS updated. During this time the link above may display a “site unreachable” message.
{{% /notice %}}

To visit the Sock Shop app, navigate to the Load Balancer address in your browser. Click the “Catalogue” tab along the top of the page and you should see a variety of sock products.

![sock_shop](/images/pixie/sock_shop.png)

### Trigger the microservices application bug

This app has several bugs. One bug in the app is that filtering the catalogue doesn't work when two or more filters are selected.

- Navigate to the "Catalogue" tab
- Select at least two tags from the left "Filter" panel, for example `geek` and `formal`.
- Press `Apply`.
- Notice that no socks show up when two or more filters are selected.
- Press `Clear` to clear the filters between retries.
- You can repeat this as many times as you want.

{{% notice info %}}
Make sure to trigger this bug for yourself. We will use Pixie to investigate this application bug.
{{% /notice %}}
