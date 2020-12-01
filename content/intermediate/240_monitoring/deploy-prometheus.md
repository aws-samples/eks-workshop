---
title: "Deploy Prometheus"
date: 2018-10-14T20:33:02-04:00
weight: 10
draft: false
---

#### Deploy Prometheus

First we are going to install Prometheus. In this example, we are primarily going to use the standard configuration, but we do override the
storage class. We will use [gp2 EBS volumes](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html) for
simplicity and demonstration purpose. When deploying in production, you would use
[io1](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html) volumes
with desired IOPS and increase the default storage size in the manifests to get better performance. Run the following command:

```bash
kubectl create namespace prometheus

helm install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set alertmanager.persistentVolume.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"
```

Make note of the prometheus endpoint in helm response (you will need this later). It should look similar to below:

```text
The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
prometheus-server.prometheus.svc.cluster.local
```

Check if Prometheus components deployed as expected

```sh
kubectl get all -n prometheus
```

You should see response similar to below. They should all be Ready and Available

{{< output >}}
NAME                                                 READY   STATUS    RESTARTS   AGE
pod/prometheus-alertmanager-868f8db8c4-67j2x         2/2     Running   0          78s
pod/prometheus-kube-state-metrics-6df5d44568-c4tkn   1/1     Running   0          78s
pod/prometheus-node-exporter-dh6f4                   1/1     Running   0          78s
pod/prometheus-node-exporter-v8rd8                   1/1     Running   0          78s
pod/prometheus-node-exporter-vcbjq                   1/1     Running   0          78s
pod/prometheus-pushgateway-759689fbc6-hvjjm          1/1     Running   0          78s
pod/prometheus-server-546c64d959-qxbzd               2/2     Running   0          78s

NAME                                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/prometheus-alertmanager         ClusterIP   10.100.38.47     <none>        80/TCP     78s
service/prometheus-kube-state-metrics   ClusterIP   10.100.165.139   <none>        8080/TCP   78s
service/prometheus-node-exporter        ClusterIP   None             <none>        9100/TCP   78s
service/prometheus-pushgateway          ClusterIP   10.100.150.237   <none>        9091/TCP   78s
service/prometheus-server               ClusterIP   10.100.209.224   <none>        80/TCP     78s

NAME                                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/prometheus-node-exporter   3         3         3       3            3           <none>          78s

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/prometheus-alertmanager         1/1     1            1           78s
deployment.apps/prometheus-kube-state-metrics   1/1     1            1           78s
deployment.apps/prometheus-pushgateway          1/1     1            1           78s
deployment.apps/prometheus-server               1/1     1            1           78s

NAME                                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/prometheus-alertmanager-868f8db8c4         1         1         1       78s
replicaset.apps/prometheus-kube-state-metrics-6df5d44568   1         1         1       78s
replicaset.apps/prometheus-pushgateway-759689fbc6          1         1         1       78s
replicaset.apps/prometheus-server-546c64d959               1         1         1       78s
{{< /output >}}

In order to access the Prometheus server URL, we are going to use the [kubectl port-forward](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) command to access the application. In Cloud9, run:

```bash
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090
```

In your Cloud9 environment, click **Tools / Preview / Preview Running Application**.
Scroll to the end of the URL and append:

{{< output >}}
/targets
{{< /output >}}

In the web UI, you can see all the targets and metrics being monitored by Prometheus:

![prometheus-targets](/images/prometheus-targets.png)
