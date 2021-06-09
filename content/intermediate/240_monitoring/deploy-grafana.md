---
title: "Deploy Grafana"
date: 2018-10-14T20:54:13-04:00
weight: 15
draft: false
---

We are now going to install Grafana. For this example, we are primarily using the Grafana defaults,
but we are overriding several parameters. As with Prometheus, we are setting the storage class
to gp2, admin password, configuring the datasource to point to Prometheus and creating an
[external load](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/)
balancer for the service.

Create YAML file called `grafana.yaml` with following commands:

```bash
mkdir ${HOME}/environment/grafana

cat << EoF > ${HOME}/environment/grafana/grafana.yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      url: http://prometheus-server.prometheus.svc.cluster.local
      access: proxy
      isDefault: true
EoF
```

```bash
kubectl create namespace grafana

helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword='EKS!sAWSome' \
    --values ${HOME}/environment/grafana/grafana.yaml \
    --set service.type=LoadBalancer
```

Run the following command to check if Grafana is deployed properly:

```bash
kubectl get all -n grafana
```

You should see similar results. They should all be Ready and Available

{{< output >}}
NAME                          READY   STATUS    RESTARTS   AGE
pod/grafana-f64dbbcf4-794rk   1/1     Running   0          55s
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP                                                               PORT(S)        AGE
service/grafana   LoadBalancer   10.100.60.167   aa0fa7322d86e408786cdd21ebcc461c-1708627185.us-east-2.elb.amazonaws.com   80:31929/TCP   55s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana   1/1     1            1           55s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-f64dbbcf4   1         1         1       55s
{{< /output >}}

{{% notice warning %}}
It can take several minutes before the ELB is up, DNS is propagated and the nodes are registered.
{{% /notice %}}

You can get Grafana ELB URL using this command. Copy & Paste the value into browser to access Grafana web UI.

```bash
export ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "http://$ELB"
```

When logging in, use the username **admin** and get the password hash by running the following:

```bash
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
