---
title: "Deploy kubenav - Navigator for Kubernetes"
date: 2020-09-19T00:19:00+05:30
weight: 10
---

As an alternative to [the official Kubernetes dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/), we can deploy `kubenav` - another web UI for managing Kubernetes clusters. The dashboard is available as a mobile ([App Store](https://apps.apple.com/us/app/kubenav/id1494512160) and [Google Play](https://play.google.com/store/apps/details?id=io.kubenav.kubenav)), [desktop](https://github.com/kubenav/kubenav/releases) and web applications. This section describes the web application as deployed to our cluster.

There are two ways to deploy the application: `kubectl` and [Helm](https://helm.sh) charts. In this section, we will focus on the `kubectl` option.

Run the following command to deploy `kubenav`. This command uses [`kustomize`](https://kustomize.io/) to generate the appropriate YAML and applies the same on to the cluster. For more details, see the repo [kubenav/deploy](https://github.com/kubenav/deploy).

```bash
kubectl apply --kustomize github.com/kubenav/deploy/kustomize
```

The following should be the output of running the above command.

```bash
namespace/kubenav created
serviceaccount/kubenav created
clusterrole.rbac.authorization.k8s.io/kubenav unchanged
clusterrolebinding.rbac.authorization.k8s.io/kubenav unchanged
service/kubenav created
deployment.apps/kubenav created
```

**Note** that, `namespace/kubenav` is created as part of the script. This means, artefacts such as `Deployment`, `Service` and others are also created in the `kubenav` namespace.  Thus, to know more about the `kubenav` `Service`, we use the `-n` (or, `--namespace`) flag for our `kubectl` command as shown below.

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
