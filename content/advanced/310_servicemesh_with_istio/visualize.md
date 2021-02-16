---
title: "Monitor & Visualize"
date: 2018-11-13T22:42:01+09:00
weight: 60
draft: false
---

## Install Grafana and Prometheus

Istio provides a basic sample installation to quickly get Prometheus and Grafana up and running, bundled with all of the Istio dashboards already installed:

```bash
export ISTIO_RELEASE=$(echo $ISTIO_VERSION |cut -d. -f1,2)

# Install Prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/prometheus.yaml

# Install Grafana
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-${ISTIO_RELEASE}/samples/addons/grafana.yaml
```

We can now verify that they have been installed:

```bash
kubectl -n istio-system get deploy grafana prometheus
```

{{< output >}}
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
grafana      1/1     1            1           63s
prometheus   1/1     1            1           64s
{{< /output >}}

## Collecting new telemetry data

Open a new terminal tab and setup port-forwarding for Grafana by executing the following command

```bash
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 8080:3000
```

Open the Istio Dashboard via the Grafana UI

* In your Cloud9 environment, click **Preview / Preview Running Application**

![Open Grafana](/images/istio/istio_grafana_open.png)

* Scroll to **the end of the URL** and append:

```bash
dashboard/db/istio-mesh-dashboard
```

* Click the 'Pop Out Into New Window' button

![Grafana FullScreen](/images/istio/istio_grafana_fullscreen.png)

Open a new terminal tab and use these commands to send a traffic to the mesh

```bash
export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

watch --interval 1 curl -s -I -XGET "http://${GATEWAY_URL}/productpage"
```

You will see that the traffic is evenly spread between <span style="color:orange">reviews:v1</span> and <span style="color:blue">reviews:v3</span>

![Grafana Dashboard](/images/istio/istio_grafana1.png)

We encourage you to explore other Istio dashboards that are available by clicking the **Istio Mesh Dashboard** menu on top left of the page, and selecting a different dashboard.
