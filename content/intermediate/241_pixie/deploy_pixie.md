---
title: "Deploy Pixie"
date: 2021-5-01T09:00:00-00:00
weight: 10
draft: false
---

### Install Pixie's CLI

Install Pixie’s CLI tool using the install script:

```bash
bash -c "$(curl -fsSL https://withpixie.ai/install.sh)"
```

- Press enter to accept the Terms & Conditions.
- Press enter to accept the default install path.
- Visit the provided URL to sign in or sign up for a new Pixie account.
- Copy and paste the auth token generated in the browser into the CLI.

### Deploy Pixie

Deploy Pixie to the `eksworkshop-eksctl` cluster using the CLI:

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