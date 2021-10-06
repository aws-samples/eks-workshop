---
title: "Deploy counter app to EKS"
weight: 50
---

Now it's time to migrate our app to EKS.
We're going to do this in two stages.

First we'll move the frontend component but have it talk to the database in our old cluster.
Then we'll set up the database in EKS, migrate the data, and configure the frontend to use it instead.

The counter app deployment and service is the same as it was in kind except we added two environment varibles for the `DB_HOST` and `DB_PORT` and the service type is LoadBalancer instead of NodePort.

```bash
cat <<EOF | kubectl apply -f - 
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: counter
  labels:
    app: counter
spec:
  replicas: 2
  selector:
    matchLabels:
      app: counter
  template:
    metadata:
      labels:
        app: counter
    spec:
      containers:
      - name: counter
        image: public.ecr.aws/aws-containers/stateful-counter:latest
        env:
        - name: DB_HOST
          value: $IP
        - name: DB_PORT
          value: "30001"
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "16Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: counter
spec:
  ports:
    - port: 80
      targetPort: 8000
  type: LoadBalancer
  selector:
    app: counter
EOF
```

Now create a postgres-external service in kind that exposes postgres on a NodePort.

```bash
cat <<EOF | kubectl --context kind-kind apply -f - 
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-external
  labels:
    app: postgres
spec:
  type: NodePort
  ports:
    - port: 5432
      nodePort: 30001
  selector:
   app: postgres
EOF
```

Now you should be able to get the endpoint for your load balancer and when you load the counter app the same count will be shown in the app.

```bash
kubectl get svc
```
