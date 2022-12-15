---
title: "Deploy Istio Gateway"
date: 2019-03-20T13:36:55+01:00
weight: 30
draft: false
---

By now the foundational Istio components are deployed in your AWS EKS Cluster.

To server the external request an Istio Ingress Gateway is required. The gateway will allow traffic reach out to the applications running inside of the EKS Cluster.

![Alt text](/images/tetrate-istio-distro/Ingress.png "Ingress GW deployment")

When the task is completed - Envoy Gateway Deployment, Pod and Service will be hosted in the EKS cluster. The creation of Kubernetes service (type `LoadBalancer`) will trigger creation of AWS Classic LoadBalancer

To achieve this task we will need to create multiple kubernetes objects per below (The example below is taken from [Istio web-site](https://istio.io/latest/docs/setup/additional-setup/gateway/#deploying-a-gateway) (with slight changes)):

Namespace definition will look like this:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: tid-ingress-ns
```

Service object will trigger creation of AWS LoadBalancer and will allow calls to reach to gateway pod.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tid-ingressgateway
  namespace: tid-ingress-ns
spec:
  type: LoadBalancer
  selector:
    istio: tid-ingress-gw
  ports:
  - port: 80
    name: http
  - port: 443
    name: https
```

The Gateway Deployment will be placed in the namespace that we just created.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tid-ingressgateway-gw
  namespace: tid-ingress-ns
spec:
  selector:
    matchLabels:
      istio: tid-ingress-gw
  template:
    metadata:
      annotations:
        # Select the gateway injection template (rather than the default sidecar template)
        inject.istio.io/templates: gateway
      labels:
        # Set a unique label for the gateway. This is required to ensure Gateways can select this workload
        istio: tid-ingress-gw
        # Enable gateway injection. If connecting to a revisioned control plane, replace with "istio.io/rev: revision-name"
        sidecar.istio.io/inject: "true"
    spec:
      containers:
      - name: istio-proxy
        image: auto # The image will automatically update each time the pod starts.
```

Role and Role bindings are also required per below. This allows the gateway to access kubernetes secrets. Kubernetes secrets are used to store TLS certificates.

```yaml
# Set up roles to allow reading credentials for TLS
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tid-ingressgateway-sds
  namespace: tid-ingress-ns
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tid-ingressgateway-sds
  namespace: tid-ingress-ns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: tid-ingressgateway-sds
subjects:
- kind: ServiceAccount
  name: default
```

To confirm that the steps worked as expected you can query `tid-ingress-ns` with the following command - `kubectl get pods -n tid-ingress-ns`

The result should show Ingress GW Pod running:
![Alt text](/images/tetrate-istio-distro/GW_Validate.png "Validating GW point")
