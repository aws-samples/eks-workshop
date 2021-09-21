---
title: "Deploy database to EKS"
weight: 60
---

The final step is to move the database from our kind cluster into EKS.
There are **lots** of different options for how you might want to migrate application state.
In many cases using an external database such as [Amazon Relational Database Service (RDS)](https://aws.amazon.com/rds/) is a great fit.

For production data you'll want to set up a way where you can verify correctness of your state or automatic syncing between environments.
For this workshop we're going to manually move our database state.

The first thing we need to do is create a Postgres database with hostPath persistent storage in Kubernetes.
We'll use the exact same ConfigMap from kind to generate an empty database first.

All of the config for Postgres is the same as it was for kind

```bash
cat <<EOF | kubectl apply -f - 
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

Deploy the postgres StatefulSet

```bash
cat <<EOF | kubectl apply -f - 
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
EOF
```

Backup the data from our kind Postgres database and restore it to EKS using standard postgres tools.

```
kubectl --context kind-kind exec -t postgres-0 -- pg_dumpall -c -U postgres > postgres_dump.sql
```

Restore database

```bash
cat postgres_dump.sql | kubectl exec -i postgres-0 -- psql -U postgres
```

Now we can deploy a postgres service inside EKS to point to the new database endpoint.
This is the exact same postgres service we deployed to kind.

```bash
cat <<EOF | kubectl apply -f - 
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

Finally we need to update the counter application to remove the two environment variables we added for the external database.

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
  replicas: 1
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
EOF
```

Open your browser to this link

```
echo "http://"$(kubectl get svc counter --output jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```
