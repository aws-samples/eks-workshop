---
title: "Deploy the Official Kubernetes Dashboard"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

The official Kubernetes dashboard is not deployed by default, but there are
instructions in [the official documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

We can deploy the dashboard with the following command:

```bash
export DASHBOARD_VERSION="v2.0.0"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
```

Since this is deployed to our private cluster, we need to access it via a proxy.
`kube-proxy` is available to proxy our requests to the dashboard service.  In your
workspace, run the following command:

```bash
kubectl proxy --port=8080 --address=0.0.0.0 --disable-filter=true &
```

This will start the proxy, listen on port 8080, listen on all interfaces, and
will disable the filtering of non-localhost requests.

This command will continue to run in the background of the current terminal's session.

{{% notice warning %}}
We are disabling request filtering, a security feature that guards against XSRF attacks.
This isn't recommended for a production environment, but is useful for our dev environment.
{{% /notice %}}

As an alternative to [the official Kubernetes dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/), we can deploy `kubenav` - another web UI for managing Kubernetes clusters. The dashboard is available as a mobile ([App Store](https://apps.apple.com/us/app/kubenav/id1494512160) and [Google Play](https://play.google.com/store/apps/details?id=io.kubenav.kubenav)), [desktop](https://github.com/kubenav/kubenav/releases) and web application. This section describes the web application as deployed to our cluster.

There are two ways to deploy the application: `kubectl` and [Helm](https://helm.sh) charts. In this section, we will focus on the `kubectl` option.

Run the following command to deploy `kubenav`. This command uses [`kustomize`](https://kustomize.io/) to generate the appropriate YAML and applies the same on to the cluster. For more details, see the repo [kubenav/deploy](https://github.com/kubenav/deploy).

```bash
kubectl apply --kustomize github.com/kubenav/deploy/kustomize
```

To look for the result, we can look for service with the following command. **Note**, this command is run on the `kubenav` namespace with the `-n` flag. This is because, the deployment (in the previous step) creates the `kubenav` namespace when deploying.

```bash
kubectl -n kubenav get svc
```

You should see output as shown below.

```bash
NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)      AGE
kubenav   ClusterIP   10.100.75.33   <none>        14122/TCP    17m
```

The dashboard can be accessed with port forwarding using the following command.

```bash
kubectl port-forward -n kubenav svc/kubenav 14122
```

The port `14122` comes from the value set in [`Service` YAML](https://github.com/kubenav/deploy/blob/master/kustomize/service.yaml).

The dashboard can now be accessed at `http://localhost:14122`.
