---
title: "Deploy Pixie"
date: 2021-5-01T09:00:00-00:00
weight: 10
draft: false
---

### Install Pixie's CLI

Install Pixie’s CLI tool using the install script.

```bash
bash -c "$(curl -fsSL https://withpixie.ai/install.sh)"
```

- Press enter to accept the Terms & Conditions.
- Press enter to accept the default install path.
- Visit the provided URL to sign in or sign up for a Pixie account.
- Copy and paste the auth token generated in the browser into the CLI.

### Deploy the microservices demo

To test out Pixie, we will deploy a modified version of [Weavework’s Sock Shop](https://microservices-demo.github.io/) microservices application. Deploy the demo using Pixie’s CLI:

```bash
px demo deploy px-sock-shop
```

- Enter `y` to confirm the cluster.

{{% notice info %}}
Deploying the microservices demo will take about 7-9 minutes.
{{% /notice %}}

Confirm that the application components have been deployed:

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

### Deploy Pixie

Use Pixie’s CLI to deploy Pixie:

```bash
px deploy --cluster_name eksworkshop-eksctl --pem_memory_limit=1Gi
```

- Enter `y` to confirm the cluster to deploy pixie to.

{{% notice info %}}
Deploying Pixie will take about 5 minutes.
{{% /notice %}}

Check if the Pixie components have been deployed:

```bash
kubectl get pods -n pl
```

You should see output similar to below. All pods should be ready and available before proceeding.

{{< output >}}
NAME                                      READY   STATUS    RESTARTS   AGE
kelvin-7749f484bc-9vmrd                   1/1     Running   0          2m14s
nats-operator-7d686798f4-tkjn4            1/1     Running   0          2m28s
pl-nats-1                                 1/1     Running   0          2m21s
vizier-certmgr-5bc8d5dcc8-grrqt           1/1     Running   0          2m14s
vizier-cloud-connector-5cdf4ccb94-crz8p   1/1     Running   0          2m14s
vizier-metadata-0                         1/1     Running   0          2m13s
vizier-pem-5fs5d                          1/1     Running   0          2m13s
vizier-pem-5kxm5                          1/1     Running   0          2m13s
vizier-pem-b79fz                          1/1     Running   0          2m13s
vizier-pem-c5bh8                          1/1     Running   0          2m13s
vizier-pem-ddjvw                          1/1     Running   0          2m13s
vizier-pem-rx7f4                          1/1     Running   0          2m13s
vizier-proxy-7c75497cdd-4lzm5             1/1     Running   0          2m13s
vizier-query-broker-6f7fc849f-wdpcz       1/1     Running   0          2m13s
{{< /output >}}

### Trigger the Application Bug

To visit the Sock Shop application, we need the external IP of the `front-end` service. Run:

```bash
kubectl -n px-sock-shop get svc front-end --watch
```

You should see output similar to that below.

{{< output >}}
NAME        TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)        AGE
front-end   LoadBalancer   10.100.116.239   a8821cbb76e3f4735999aeb22965f81d-258266119.us-west-2.elb.amazonaws.com   80:30001/TCP   2m22s
{{< /output >}}

Navigate to the “External-IP” address in your browser.

Click the “Catalogue” tab along the top of the page and you should see a variety of sock products.

![sock_shop](/images/pixie/sock_shop.png)

This app has several bugs. One bug in the app is that filtering the catalogue doesn't work when two or more filters are selected.

- Select at least two tags on the left panel, for example `geek` and `formal`.
- Press `Apply`.
- Notice that no socks show up when two or more filters are selected.
- Make sure you hit `Clear` to clear and reselect the filters between retries.
- You can repeat this as many times as you want.

{{% notice info %}}
Make sure to trigger this bug yourself. We will use Pixie to investigate this application bug.
{{% /notice %}}
