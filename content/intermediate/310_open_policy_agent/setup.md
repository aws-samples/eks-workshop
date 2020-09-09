---
title: "OPA setup in EKS"
weight: 15
draft: false
---

In this section, we will setup `OPA` within the cluster.



#### 1. Create a new Namespace to deploy OPA into

When OPA is deployed on top of Kubernetes, policies are automatically loaded out of ConfigMaps in the opa namespace. Configure `kubectl` to use the `opa` namespace.

```
kubectl create namespace opa

kubectl config set-context --namespace opa --current
```

#### 2. Secure communication between Kubernetes and OPA using TLS.

Create an OPA directory to store configuration files:

```
mkdir -p ~/environment/opa && cd ~/environment/opa/
```

To configure TLS, use openssl to create a certificate authority (CA) and certificate/key pair for OPA.

```
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"
```

Generate the TLS key and certificate for OPA:

```
cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF
```

```
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=opa.opa.svc" -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf
```

#### 3. Create a Secret to store the TLS credentials for OPA

```
kubectl create secret tls opa-server --cert=server.crt --key=server.key
```

#### 4. Deploy OPA as an Admission Controller

Next, use the file below to deploy OPA as an admission controller.

```
cat >admission-controller.yaml <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: opa-viewer
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: Group
  name: system:serviceaccounts:opa
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: opa
  name: configmap-modifier
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: opa
  name: opa-configmap-modifier
roleRef:
  kind: Role
  name: configmap-modifier
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: Group
  name: system:serviceaccounts:opa
  apiGroup: rbac.authorization.k8s.io
---
kind: Service
apiVersion: v1
metadata:
  name: opa
  namespace: opa
spec:
  selector:
    app: opa
  ports:
  - name: https
    protocol: TCP
    port: 443
    targetPort: 443
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: opa
  namespace: opa
  name: opa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opa
  template:
    metadata:
      labels:
        app: opa
      name: opa
    spec:
      containers:
        - name: opa
          image: openpolicyagent/opa:0.12.2
          args:
            - "run"
            - "--server"
            - "--tls-cert-file=/certs/tls.crt"
            - "--tls-private-key-file=/certs/tls.key"
            - "--addr=0.0.0.0:443"
            - "--addr=http://127.0.0.1:8181"
          volumeMounts:
            - readOnly: true
              mountPath: /certs
              name: opa-server
        - name: kube-mgmt
          image: openpolicyagent/kube-mgmt:0.8
          args:
            - "--replicate-cluster=v1/namespaces"
            - "--replicate=extensions/v1beta1/ingresses"
      volumes:
        - name: opa-server
          secret:
            secretName: opa-server
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: opa-default-system-main
  namespace: opa
data:
  main: |
    package system

    import data.kubernetes.admission

    main = {
      "apiVersion": "admission.k8s.io/v1beta1",
      "kind": "AdmissionReview",
      "response": response,
    }

    default response = {"allowed": true}

    response = {
        "allowed": false,
        "status": {
            "reason": reason,
        },
    } {
        reason = concat(", ", admission.deny)
        reason != ""
    }
EOF
```

Apply the OPA Admission Controller to the EKS cluster:

```
kubectl apply -f admission-controller.yaml
```

#### 5. Register OPA as an Admission Controller using Validating Webhook Configuration

Next, generate the manifest that will be used to register OPA as an admission controller. This webhook will ignore any namespace with the label `openpolicyagent.org/webhook=ignore`. The generated configuration file includes a base64 encoded representation of the CA certificate so that TLS connections can be established between the Kubernetes API server and OPA.

```
cat > webhook-configuration.yaml <<EOF
kind: ValidatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1beta1
metadata:
  name: opa-validating-webhook
webhooks:
  - name: validating-webhook.openpolicyagent.org
    namespaceSelector:
      matchExpressions:
      - key: openpolicyagent.org/webhook
        operator: NotIn
        values:
        - ignore
    rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
      service:
        namespace: opa
        name: opa
EOF
```

Label kube-system and the opa namespace so that OPA does not control the resources in those namespaces.

```
kubectl label ns kube-system openpolicyagent.org/webhook=ignore
kubectl label ns opa openpolicyagent.org/webhook=ignore
```

Finally, register OPA as an admission controller:

```
kubectl apply -f webhook-configuration.yaml
```

#### 6. Observe OPA logs once operational

You can follow the OPA logs to see the webhook requests being issued by the Kubernetes API server:

```
kubectl logs -l app=opa -c opa
```

This completes the OPA setup on Amazon EKS cluster. However, we haven't loaded any policies yet as ConfigMaps. Next, we describe a governance problem, and implement a solution using an OPA policy.