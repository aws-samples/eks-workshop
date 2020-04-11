---
title: "Create Resources"
date: 2018-08-07T08:30:11-07:00
weight: 1
---

Before creating network polices, let's create the required resources.

Create a new folder for the configuration files.

```
mkdir ~/environment/calico_resources
cd ~/environment/calico_resources
```

#### Stars Namespace

Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/calico_resources
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/create_resources.files/namespace.yaml
```

Let's examine our file by running `cat namespace.yaml`.

{{< output >}}
kind: Namespace
apiVersion: v1
metadata:
  name: stars
{{< /output >}}

Create a namespace called stars:

```
kubectl apply -f namespace.yaml
```

We will create frontend and backend [replication controllers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) and [services](https://kubernetes.io/docs/concepts/services-networking/service/) in this namespace in later steps.


Copy/Paste the following commands into your Cloud9 Terminal.
```
cd ~/environment/calico_resources
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/create_resources.files/management-ui.yaml
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/create_resources.files/backend.yaml
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/create_resources.files/frontend.yaml
wget https://eksworkshop.com/beginner/120_network-policies/calico/stars_policy_demo/create_resources.files/client.yaml
```

```
cat management-ui.yaml
```
{{< output >}}
apiVersion: v1
kind: Namespace
metadata:
  name: management-ui
  labels:
    role: management-ui
---
apiVersion: v1
kind: Service
metadata:
  name: management-ui
  namespace: management-ui
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 9001
  selector:
    role: management-ui
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: management-ui
  namespace: management-ui
spec:
  replicas: 1
  template:
    metadata:
      labels:
        role: management-ui
    spec:
      containers:
      - name: management-ui
        image: calico/star-collect:v0.1.0
        imagePullPolicy: Always
        ports:
        - containerPort: 9001
{{< /output >}}

Create a management-ui namespace, with a management-ui service and replication controller within that namespace:

```
kubectl apply -f management-ui.yaml
```

`cat backend.yaml` to see how the backend service is built:

{{< output >}}
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: stars
spec:
  ports:
  - port: 6379
    targetPort: 6379
  selector:
    role: backend
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: backend
  namespace: stars
spec:
  replicas: 1
  template:
    metadata:
      labels:
        role: backend
    spec:
      containers:
      - name: backend
        image: calico/star-probe:v0.1.0
        imagePullPolicy: Always
        command:
        - probe
        - --http-port=6379
        - --urls=http://frontend.stars:80/status,http://backend.stars:6379/status,http://client.client:9000/status
        ports:
        - containerPort: 6379
{{< /output >}}

Let's examine the frontend service with `cat frontend.yaml`:

{{< output >}}
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: stars
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    role: frontend
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: frontend
  namespace: stars
spec:
  replicas: 1
  template:
    metadata:
      labels:
        role: frontend
    spec:
      containers:
      - name: frontend
        image: calico/star-probe:v0.1.0
        imagePullPolicy: Always
        command:
        - probe
        - --http-port=80
        - --urls=http://frontend.stars:80/status,http://backend.stars:6379/status,http://client.client:9000/status
        ports:
        - containerPort: 80
{{< /output >}}

Create frontend and backend replication controllers and services within the stars namespace:

```
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
```

Lastly, let's examine how the client namespace, and a client service for a replication controller
are built. `cat client.yaml`:

{{< output >}}
kind: Namespace
apiVersion: v1
metadata:
  name: client
  labels:
    role: client
---
apiVersion: v1
kind: ReplicationController
metadata:
  name: client
  namespace: client
spec:
  replicas: 1
  template:
    metadata:
      labels:
        role: client
    spec:
      containers:
      - name: client
        image: calico/star-probe:v0.1.0
        imagePullPolicy: Always
        command:
        - probe
        - --urls=http://frontend.stars:80/status,http://backend.stars:6379/status
        ports:
        - containerPort: 9000
---
apiVersion: v1
kind: Service
metadata:
  name: client
  namespace: client
spec:
  ports:
  - port: 9000
    targetPort: 9000
  selector:
    role: client
{{< /output >}}

Apply the client configuraiton.

```
kubectl apply -f client.yaml
```
Check their status, and wait for all the pods to reach the Running status:

```
kubectl get pods --all-namespaces
```
Your output should look like this:

{{< output >}}
NAMESPACE       NAME                                                  READY   STATUS    RESTARTS   AGE
client          client-nkcfg                                          1/1     Running   0          24m
kube-system     aws-node-6kqmw                                        1/1     Running   0          50m
kube-system     aws-node-grstb                                        1/1     Running   1          50m
kube-system     aws-node-m7jg8                                        1/1     Running   1          50m
kube-system     calico-node-b5b7j                                     1/1     Running   0          28m
kube-system     calico-node-dw694                                     1/1     Running   0          28m
kube-system     calico-node-vtz9k                                     1/1     Running   0          28m
kube-system     calico-typha-75667d89cb-4q4zx                         1/1     Running   0          28m
kube-system     calico-typha-horizontal-autoscaler-78f747b679-kzzwq   1/1     Running   0          28m
kube-system     kube-dns-7cc87d595-bd9hq                              3/3     Running   0          1h
kube-system     kube-proxy-lp4vw                                      1/1     Running   0          50m
kube-system     kube-proxy-rfljb                                      1/1     Running   0          50m
kube-system     kube-proxy-wzlqg                                      1/1     Running   0          50m
management-ui   management-ui-wzvz4                                   1/1     Running   0          24m
stars           backend-tkjrx                                         1/1     Running   0          24m
stars           frontend-q4r84                                        1/1     Running   0          24m
{{< /output >}}

{{% notice note %}}
It may take several minutes to download all the required Docker images.
{{% /notice %}}

To summarize the different resources we created:

* A namespace called **stars**
* **frontend** and **backend** replication controllers and services within **stars** namespace
* A namespace called **management-ui**
* Replication controller and service **management-ui** for the user interface seen on the browser, in the **management-ui** namespace
* A namespace called **client**
* **client** replication controller and service in **client** namespace
