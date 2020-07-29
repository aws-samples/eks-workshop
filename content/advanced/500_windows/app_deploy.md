---
title: "Deploy Windows application"
date: 2020-07-27T15:34:36-04:00
draft: false
weight: 530
---

We are now ready to deploy our Windows IIS container

```bash
kubectl create namespace windows

kubectl apply -f https://www.eksworkshop.comadvanced/500_windows/app_deploy/deploy.files/windows_server_iis.yaml

```

Let's verify what we just deployed

```bash
kubectl -n windows get svc,deploy,pods
```

Finally, we will connect to the load-balancer

```bash
export WINDOWS_IIS_SVC=$(kubectl -n windows get svc -o jsonpath='{.items[].status.loadBalancer.ingress[].hostname}')

echo http://${WINDOWS_IIS_SVC}
```

Output

![Windows IIS Welcome screen](/images/windows/windows_iis_welcome.png)
