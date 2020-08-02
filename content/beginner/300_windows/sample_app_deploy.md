---
title: "Deploy an application"
date: 2020-07-27T15:34:36-04:00
draft: false
weight: 330
---

### NodeSelector

You must specify node selectors on your applications so that the pods land on a node with the appropriate operating system.

For Linux pods, use the following node selector text in your manifests.
{{< output >}}
nodeSelector:
        kubernetes.io/os: linux
        kubernetes.io/arch: amd64
{{< /output>}}

For Windows pods, use the following node selector text in your manifests.

{{< output>}}
nodeSelector:
        kubernetes.io/os: windows
        kubernetes.io/arch: amd64
{{< /output>}}

{{% notice tip %}}
Our deployment file already has the proper node selectors so you won't have to add them yourself.
{{% /notice %}}

{{%attachments title="Related files" pattern=".yaml"/%}}

### Deploy a Windows sample application

We are now ready to deploy our Windows IIS container

```bash
kubectl create namespace windows

kubectl apply -f https://www.eksworkshop.com/beginner/300_windows/sample_app_deploy.files/windows_server_iis.yaml
```

Let's verify what we just deployed

```bash
kubectl -n windows get svc,deploy,pods
```

{{< output >}}
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)        AGE
service/windows-server-iis-service   LoadBalancer   10.100.114.95   a52bab64f1fb34b338104c4ab20eb867-195815018.us-east-2.elb.amazonaws.com   80:31184/TCP   68s
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/windows-server-iis   1/1     1            1           68s

NAME                                      READY   STATUS    RESTARTS   AGE
pod/windows-server-iis-7cff879775-7t8hk   1/1     Running   0          68s
{{< /output >}}

{{% notice info %}}
It will take several minutes for the ELB to become healthy and start passing traffic to the  pods.
{{% /notice %}}

Finally, we will connect to the load-balancer

```bash
export WINDOWS_IIS_SVC=$(kubectl -n windows get svc -o jsonpath='{.items[].status.loadBalancer.ingress[].hostname}')

echo http://${WINDOWS_IIS_SVC}
```

Output

![Windows IIS Welcome screen](/images/windows/windows_iis_welcome.png)
