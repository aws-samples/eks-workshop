---
title: "Deploy counter app to kind"
weight: 20
---

Once the kind cluster is ready we can check it with

```bash
kubectl --context kind-kind get nodes
```

Deploy our postgres database to the cluster.
First create a ConfigMap to initialize an empty database and then create a PersistentVolume on hostPath to store the data.

```bash
cat <<EOF | kubectl --context kind-kind apply -f - 
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  labels:
    app: postgres
data:
  POSTGRES_PASSWORD: supersecret
  init: |
    CREATE TABLE importantdata (
    id int4 PRIMARY KEY,
    count int4 NOT NULL
    );

    INSERT INTO importantdata (id , count) VALUES (1, 0);
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: postgres-pv-volume
  labels:
    type: local
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mnt/data"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-pv-claim
  labels:
    app: postgres
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
EOF
```

Now deploy a Postgres StatefulSet and service.
You can see we mount the ConfigMap and PersistentVolumeClaim

```bash
cat <<EOF | kubectl --context kind-kind apply -f - 
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  replicas: 1
  serviceName: postgres
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      terminationGracePeriodSeconds: 5
      containers:
        - name: postgres
          image: postgres:13
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432
          envFrom:
            - configMapRef:
                name: postgres-config
          volumeMounts:
            - mountPath: /var/lib/postgresql/data
              name: postgredb
            - mountPath: /docker-entrypoint-initdb.d
              name: init
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
      volumes:
        - name: postgredb
          persistentVolumeClaim:
            claimName: postgres-pv-claim
        - name: init
          configMap:
            name: postgres-config
            items:
            - key: init
              path: init.sql
---
apiVersion: v1
kind: Service
metadata:
  name: postgres
  labels:
    app: postgres
spec:
  type: ClusterIP
  ports:
   - port: 5432
  selector:
   app: postgres
EOF
```

Finally deploy the counter frontend and NodePort service

```bash
cat <<EOF | kubectl --context kind-kind apply -f - 
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
  name: counter-service
spec:
  type: NodePort
  selector:
    app: counter
  ports:
    - port: 8000
      name: http
      nodePort: 30000
EOF
```

You can verify that your application and database is running with

```bash
kubectl --context kind-kind get pods
```
